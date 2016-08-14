class PlaylistsController < ApplicationController

include UsersHelper

  def new
    user = User.find(session[:user_id])
    spotify_user = RSpotify::User.new(user.spotify_user_hash)
    @spotify_playlists = spotify_user.playlists.map{|playlist| [playlist.name, playlist.id]}
  end

  def create
    @playlist = Playlist.new(playlist_params)

    if @playlist.save
      redirect_to playlist_admin_path(@playlist)
    else
      render :new
    end
  end

  def find
    unless logged_in?
      redirect_to new_session_path
    end
  end

  def verify
    if params[:id]
      @playlist = Playlist.find(params[:id])
    else
      @playlist = nil
    end

    if @playlist
      if @playlist.passcode == params[:passcode] && @playlist.passcode != nil
        redirect_to playlists_path
      elsif @playlist.admin_id == session[:user_id]
        redirect_to playlist_admin_path
      else
        render 'find'
      end
    else
      render 'find'
    end
  end

  def index
    if logged_in? && current_user.playlists
      @playlists = current_user.playlists.map{|playlist| [playlist.name, playlist.id]}
    elsif logged_in? && current_user.playlists == nil
      @playlists = []
    else
      redirect_to new_session_path
    end
  end

  def show
  end

  private
    def playlist_params
      params.permit(:spotify_id, :request_limit, :flag_minimum, :allow_explicit)
    end

end
