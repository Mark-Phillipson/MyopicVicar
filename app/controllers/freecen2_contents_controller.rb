class Freecen2ContentsController < ApplicationController
  require 'chapman_code'
  require 'freecen_constants'
  skip_before_action :require_login

  def county_index
    set_county_vars
    records_places = @freecen2_contents.records[@chapman_code][:total][:places]
    @places_for_county = {}
    @places_for_county =  {"" => "Select a Place in " + @county_description + " ..."}
    records_places.each { |place| @places_for_county[place] = add_dates_place(@chapman_code, place)}
    if params[:commit] == 'View Place Records'
      if !params[:place_description].present? || params[:place_description] == ''
        flash[:notice] = 'You must select a Place'
      else
        session[:contents_county_description] = @county_description
        session[:contents_place_description] = params[:place_description]
        redirect_to freecen2_contents_place_index_path and return
      end
    end
  end

  def new_records_index
    if session[:contents_id].blank?
      @freecen2_contents = Freecen2Content.order(interval_end: :desc).first
      session[:contents_id] = @freecen2_contents.id
    end
    @id = session[:contents_id]
    @freecen2_contents = Freecen2Content.find_by(id: @id)
    @interval_end = @freecen2_contents.interval_end
    @recent_additions = []
    @additions_county = params[:new_records]
    if @freecen2_contents.new_records.present?
      if @additions_county  == 'All'
        @recent_additions = @freecen2_contents.new_records
      else
        @freecen2_contents.new_records.each do |entry|
          # [0] = county name [1] = place name [2] = chapman code [3] = freecen2_place_id [4] = year
          if entry[0] == @additions_county
            @recent_additions << entry
          end
        end
      end
    end
  end

  def place_index
    set_county_vars
    if params[:place_description].present?
      @place_description = params[:place_description]
    else
      @place_description = session[:contents_place_description]
    end
    @key_place = Freecen2Content.get_place_key(@place_description)
    @place_id = @freecen2_contents.records[@chapman_code][@key_place][:total][:place_id]
    check_names_exist
  end

  def piece_index
    set_county_vars
    @last_id = BSON::ObjectId.from_time(@interval_end)
    @census = params[:census_year]
    @place_description = params[:place_description]
    @place_id = params[:place_id]
    @key_place = Freecen2Content.get_place_key(@place_description)
    if params[:census_year] == 'all'
      @census = 'All Years'
      @place_piece_ids = @freecen2_contents.records[@chapman_code][@key_place][:total][:piece_ids]
      @place_pieces = Freecen2Piece.where(:_id.in => @place_piece_ids).order_by(name: 1, year: 1, number: 1)
    else
      @census = params[:census_year]
      @place_piece_ids = @freecen2_contents.records[@chapman_code][@key_place][@census][:piece_ids]
      @place_pieces = Freecen2Piece.where(:_id.in => @place_piece_ids).order_by(name: 1, number: 1)
    end
  end

  def place_names
    set_county_vars
    @year = params[:census_year]
    @place_description = params[:place_description]
    @place = Freecen2Place.find_by(chapman_code: @chapman_code, place_name: @place_description)
    @place_unique_names = Freecen2PlaceUniqueName.find_by(freecen2_place_id: @place.id)
    @first_names = @place_unique_names.unique_forenames[@year]
    @last_names = @place_unique_names.unique_surnames[@year]
    @first_names_cnt = @first_names.count
    @last_names_cnt = @last_names.count
    if params[:name_type] == "Surnames" ||  params[:name_type].to_s.empty?
      @unique_names = @last_names
      @name_type = 'Surnames'
    else
      @unique_names = @first_names
      @name_type = 'Forenames'
    end
    if params[:first_letter].present?
      @first_letter = params[:first_letter]
    else
      @first_letter = 'All'
    end
    @unique_names, @remainder = Freecen2Content.letterize(@unique_names)
  end

  def create
    @freecen2_content = Freecen2Content.new(freecen2_content_params)
    @freecen2_content.save
    if @freecen2_content.errors.any?
      flash[:notice] = 'There were errors'
      redirect_to(new_freecen2_content_path(@freecen2_content)) && return
    end
    redirect_to(freecen2_content_path(@freecen2_content))
  end

  def new
    @freecen2_content = Freecen2Content.new
  end

  def index
    @freecen2_contents = Freecen2Content.order(interval_end: :desc).first
    @interval_end = @freecen2_contents.interval_end
    session[:contents_id] = @freecen2_contents.id
    records_counties = @freecen2_contents.records[:total][:counties]
    @all_counties = {}
    @all_counties =  {"" => "Select a County ... "}
    records_counties.each { |county| @all_counties[county] = county}
    if params[:commit] == 'View County Records'
      session[:contents_county_description] = params[:county_description]
      redirect_to index_by_county_freecen2_contents_path and return
    else
      if params[:commit] == 'View Place Records'
        if !params[:place_description].present? || params[:place_description] == ''
          flash[:notice] = 'You must select a Place'
        else
          session[:contents_county_description] = params[:county_description]
          session[:contents_place_description] = params[:place_description]
          redirect_to freecen2_contents_place_index_path and return
        end
      end
    end
  end

  def for_place_names
    @id = session[:contents_id]
    @freecen2_contents = Freecen2Content.find_by(id: @id)
    if params[:county_description]
      county_description = params[:county_description]
    else
      log_possible_host_change
      county_description = ''
    end
    chapman_code = ChapmanCode.code_from_name(county_description)
    county_places = @freecen2_contents.records[chapman_code][:total][:places]
    county_places_hash = {"" => "Select a Place in " + county_description + " ..."}
    county_places.each { |place| county_places_hash[place] =  add_dates_place(chapman_code, place)}
    if county_places_hash.present?
      respond_to do |format|
        format.json do
          render json: county_places_hash
        end
      end
    else
      flash[:notice] = 'An Error was encountered: No places found'
    end
  end

  def set_county_vars
    if session[:contents_id].blank?
      @freecen2_contents = Freecen2Content.order(interval_end: :desc).first
      session[:contents_id] = @freecen2_contents.id
    end
    @id = session[:contents_id]
    @freecen2_contents = Freecen2Content.find_by(id: @id)
    @interval_end = @freecen2_contents.interval_end
    if params[:county_description].present?
      @county_description = params[:county_description]
      session[:contents_county_description] = @county_description
    else
      @county_description = session[:contents_county_description]
    end
    @chapman_code = ChapmanCode.code_from_name(@county_description)
  end

  def check_names_exist
    @has_some_names = false
    @has_names = {}
    names_present = Freecen2PlaceUniqueName.find_by(freecen2_place_id: @place_id).present?
    if names_present
      @names =  Freecen2PlaceUniqueName.find_by(freecen2_place_id: @place_id)
      Freecen::CENSUS_YEARS_ARRAY.each do |year|
        if @names.unique_forenames[year].present? and @names.unique_surnames[year].present?
          @has_names[year] = true
          @has_some_names = true
        else
          @has_names[year] = false
        end
      end
    end
  end

  def add_dates_place(chapman_code, place_description)
    place_dropdown = place_description
    key_place = Freecen2Content.get_place_key(place_description)
    if @freecen2_contents.records[chapman_code][key_place][:total][:records_online] > 0
      place = Freecen2Place.find_by(chapman_code: chapman_code, place_name: place_description)
      if !place.cen_data_years.blank?
        years = "(" + place.cen_data_years.to_s.gsub(/\"|\[|\]/,"") + ")"
        place_dropdown = place_description + ' ' + years
      end
    end
    return place_dropdown
  end

  private

  def freecen2_content_params
    params.require(:freecen2_content).permit!
  end
end
