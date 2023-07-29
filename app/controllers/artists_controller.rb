class ArtistsController < ApplicationController
  PER_PAGE = 30.freeze

  def show
    artist = Artist.find(params[:id])
    albums = selected_albums(artist.albums, params[:album_type]).with_attached_cover.preload(:artist)
    tracks = artist.tracks.popularity_ordered.limit(5)

    if turbo_frame_request?
      render partial: "discography", locals: {artist:, albums:}
    else
      render action: :show, locals: {artist:, albums:, tracks:}
    end
  end

  def tracks
    artist = Artist.find(params[:id])
    page = params[:page] ? params[:page].to_i : 1
    offset = (page - 1) * PER_PAGE
    tracks = artist.tracks.offset(offset).limit(PER_PAGE)
    next_page = page + 1 if tracks.size == PER_PAGE

    if turbo_frame_request?
      render partial: "tracks/lazy_list", locals: {artist:, tracks:, page:, next_page:}
    else
      render action: "tracks", locals: {artist:, tracks:, page:, next_page:}
    end
  end

  private

  def selected_albums(albums, album_type)
    return albums.lp if album_type.blank?

    return albums.lp unless Album.kinds.key?(album_type)

    albums.where(kind: album_type)
  end
end
