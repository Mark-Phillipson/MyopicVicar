module Freecen1VldFilesHelper

  def edit_freecen1_vld_file
    link_to 'Edit Transcriber', edit_freecen1_vld_file_path(@freecen1_vld_file, type: 'transcriber'), method: :get, class: 'btn   btn--small', title: 'Allows you to enter/edit the name of the person who transcribed the file.'
  end

  def piece_link(vld)
    piece = vld.freecen_piece
    link_to "#{vld.piece}", freecen_piece_path(piece.id), class: 'btn   btn--small'
  end
end
