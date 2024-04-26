#-------------------------------------------------------------------------------------------------------#
#GUI Music Player 
#by Matthew De Silva 
#-------------------------------------------------------------------------------------------------------#
require 'rubygems'
require 'gosu'
require 'audioinfo'

#Declaring Global Variables
TOP_COLOR = Gosu::Color.argb(0xFFFFC8BE)
BOTTOM_COLOR = Gosu::Color::BLACK
SCREEN_W = 1000
SCREEN_H = 1500
ALBUM_SIZE = 190

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

class Artwork
	attr_accessor :bmp
	def initialize(file)
		puts("Attempting to load image from: #{file}")
		@bmp = Gosu::Image.new(file)
	end
end

class Album
	attr_accessor  :album_num, :artist, :title, :genre, :artwork, :tracks
	def initialize (album_num, artist, title, genre, artwork, tracks)
		  @album_num = album_num
    	  @artist = artist
          @title = title
          @genre = genre
		  @artwork = artwork
          @tracks = tracks
	end
end

class Track
	attr_accessor :name, :location
	def initialize(name, location)
		@name = name
		@location = location
	end
end

class MusicPlayerMain < Gosu::Window

	def initialize
		#Gosu screen
	    super SCREEN_W, SCREEN_H
	    self.caption = "Music Player"

		file = File.new("albums.txt", "r")
	    @albums = read_albums(file)

		#Declaring global variables
		@track_select = nil
		@song_select = nil
		@display_num = nil
		@playlist_selected = false
		@SonginPlay = false

		@start_index = 0

	    @track_font = Gosu::Font.new(25)

		@selected_genre_albums = []
		@playlist = []
		@genre_list = []

		# Extract unique genres
		@albums.each do |album|
			genre = album.genre
			@genre_list << genre if genre && !@genre_list.include?(genre)
		end

		#Checks how much albums the screen has room for
		if (ALBUM_SIZE * 4) <= (SCREEN_W - 240) 
    		@display_num = 4
		elsif (ALBUM_SIZE * 3) <= (SCREEN_W + - 240) 
    		@display_num = 3
		elsif (ALBUM_SIZE * 2) <= (SCREEN_W + - 240) 
    		@display_num = 2
		else
			window.close
			puts("Error: Album size too big for program")
		end
	end

	def play_music(song)
		if File.exist?(song)
			@song = Gosu::Song.new(song)
			@song.play

			audio_info = AudioInfo.new(song)
			@duration = audio_info.length
			@start_time = Gosu.milliseconds

			puts("Selected Song: " + @song_select.name.to_s)
			@SonginPlay = true
		else
			puts("Error: Song Not Found")
		end
	end


#----------------------------------READING FILE---------------------------------------------------------------------#

  	# Reads a single track
	def read_track(music_file)
		name = music_file.gets.chomp.to_s
		location = music_file.gets.chomp.to_s
		track = Track.new(name, location)
		return track
	end

	# Reads tracks creates array
	def read_tracks(music_file)
  		count = music_file.gets().to_i
  		tracks = []
  		count.times do
    		track = read_track(music_file)
    		tracks << track
  	end
  		return tracks
	end

	# Reads albums creates array
	def read_albums(music_file)
		album_num = music_file.gets.chomp.to_i
		albums = Array.new()

		while album_num > 0
			album = read_album(music_file, album_num)
			albums << album
			album_num += -1
		end
	return albums
	end

	# Reads a single album
	def read_album(music_file, album_num)
		album_artist = music_file.gets.chomp.to_s
		album_title = music_file.gets.chomp.to_s
		genre = music_file.gets.chomp.to_s
		artwork = Artwork.new(music_file.gets.chomp)
		tracks = read_tracks(music_file)
		album = Album.new(album_num, album_artist, album_title, genre, artwork, tracks)
		return album
	end


#----------------------------------MOUSE DETECTION---------------------------------------------------------------------#

	# Detects if a 'mouse sensitive' area has been clicked on
	# i.e either an album or a track. returns true or false
	def area_clicked_album(leftX, topY, rightX, bottomY)
		if mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY
			return true
		end
		return false
	end

	# TRACK FOR PLAYER - Checks each position downwards depending on no. tracks - spacing 56px
	def area_clicked_track(tracks)
		counter = 0
		if @playlist_selected == true
			inital_gap = 430
		else
			inital_gap = 330
		end
		while tracks.length > counter
			if mouse_x > 140 && mouse_x < 800 && mouse_y > (56 * counter + inital_gap + ALBUM_SIZE) && mouse_y < (56 * counter + (inital_gap + 60) + ALBUM_SIZE)
				if File.exist?(tracks[counter].location)
					@song_select = tracks[counter]
					return true
				else
					puts("Error: Song Not Found")
					return false
				end
			end
			counter += 1
		end
		return false
	end 

	# TRACK FOR PLAYLIST - Checks each position downwards depending on no. tracks - spacing 56px
	def area_clicked_track_add(tracks)
		counter = 0
		if @playlist_selected != true
			while tracks.length > counter
				if mouse_x > 801 && mouse_x < 855 && mouse_y > (56 * counter + 330 + ALBUM_SIZE) && mouse_y < (56 * counter + 390 + ALBUM_SIZE)
					track_to_add = tracks[counter]
					

					# Check if the track is already in the playlist
					if @playlist.include?(track_to_add)
						@playlist.delete(track_to_add) # Remove the track from the playlist
					else
						@playlist << track_to_add  # Add the track to the playlist
					end
				return true
				end
			counter += 1
			end
		end
		return false
	end 

	# Mouse within Pause/Play button 
	def area_clicked_playbutton()
		if mouse_x > 475 && mouse_x < 510 && mouse_y > 180 && mouse_y < 215
			return true
		end
		return false
	end 

	# Mouse within Back/Skip Button
	def area_clicked_skiporbackbutton()
		if mouse_x > 545 && mouse_x < 575 && mouse_y > 180 && mouse_y < 215
		  return 1
		elsif mouse_x > 420 && mouse_x < 455 && mouse_y > 180 && mouse_y < 215
		  return -1
		end
		return 0  # Return 0 if neither button is clicked
	  end

	# Mouse within back button 
	def area_clicked_back_triangle
		if mouse_x > 15 && mouse_x < 50 && mouse_y > 300 && mouse_y < 500
			return true
		end
		return false
	end

 	# Mouse within forward button 
	def area_clicked_forward_triangle
		if mouse_x > 950 && mouse_x < 985 && mouse_y > 300 && mouse_y < 500
			return true
		end
		return false
	end

	# Mouse within genre buttons
	def area_clicked_genre(index)
		current = 100 * (index + 1) + 100
		if mouse_x > current && mouse_x < current + 80 && mouse_y > 240 && mouse_y < 260
			return true
		end
		return false
	end

	# Mouse within de-select button
	def area_clicked_de_select()
		if mouse_x > 800 && mouse_x < 900 && mouse_y > 240 && mouse_y < 260
			return true
		end
		return false
	end

	# Mouse within playlist button
	def area_clicked_playlist_button()
		if mouse_x > 65 && mouse_x < 235 && mouse_y > 1295 && mouse_y < 1355
			return true
		end
		return false
	end

	#----------------------------------DRAW---------------------------------------------------------------------#

	# CASE - No tracks
	def display_tracks(album)
		counter = 0 
		if album.length == 0
			@track_font.draw("No Tracks", 150, 540, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::RED)
		else
	
	# CASE - tracks
	# Prints track text with - spacing 56 px translated down 360 pixels plus albums height
		start_distance = 360 
			if @playlist_selected == true
				text_gap = 56 * counter + start_distance + ALBUM_SIZE
				@track_font.draw("CUSTOM PLAYLIST", 150, text_gap, ZOrder::PLAYER, 2.0, 2.0, Gosu::Color::RED)
				start_distance = 460
			else
				font = Gosu::Font.new(20)
				font.draw("Album: ", 145, 520, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
				font.draw(@track_select.title, 145 + font.text_width("Album: "), 520, ZOrder::UI, 1.0, 1.0, Gosu::Color::GRAY) 
				font.draw("Artist: ", 145 + font.text_width("Album: " + @track_select.title + " "), 520, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
				font.draw(@track_select.artist, 145 + font.text_width("Album: " + @track_select.title + " Artist: "), 520, ZOrder::UI, 1.0, 1.0, Gosu::Color::GRAY) 
			end
			while album.length > counter
				text_gap = 56 * counter + start_distance + ALBUM_SIZE
				track = album
				@track_font.draw(track[counter].name, 150, text_gap, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::WHITE)
	
				# Prints track BACKGROUND box - spacing 60 px		
				top_y = text_gap - 30  
				bottom_y = text_gap + 30 
				draw_quad(140, top_y, Gosu::Color.new(100, 0, 0, 0), 860, top_y, Gosu::Color.new(100, 0, 0, 0), 140, bottom_y, Gosu::Color.new(100, 0, 0, 0), 860, bottom_y, Gosu::Color.new(100, 0, 0, 0), ZOrder::BACKGROUND)
				counter += 1

				if @playlist.include?(track[counter - 1])
					draw_quad(820, top_y + 15, Gosu::Color::GREEN, 850, top_y + 15, Gosu::Color::GREEN, 820, bottom_y - 15, Gosu::Color::GREEN, 850, bottom_y - 15, Gosu::Color::GREEN, ZOrder::BACKGROUND)
				else
					draw_quad(820, top_y + 15, Gosu::Color::WHITE, 850, top_y + 15, Gosu::Color::WHITE, 820, bottom_y - 15, Gosu::Color::WHITE, 850, bottom_y - 15, Gosu::Color::WHITE, ZOrder::BACKGROUND)
				end
			end
		end
	end

	# Draws albums on screen
	def draw_albums(albums, start_index)
			albums[start_index, @display_num].each_with_index do |album, index|

				# Calculate the scaling factor to fit the image within ALBUM_SIZE
				scale_factor = [ALBUM_SIZE.to_f / album.artwork.bmp.width, ALBUM_SIZE.to_f / album.artwork.bmp.height].min

				gap = ALBUM_SIZE / 10
				album.artwork.bmp.draw((index + 1) * (ALBUM_SIZE + gap) - 120, 300, ZOrder::PLAYER, scale_factor, scale_factor)
			end
	end

	def draw_background()
	# Draws backing gradient
		draw_quad(0, 0, TOP_COLOR, 0, SCREEN_H + 400, BOTTOM_COLOR, SCREEN_W, 0, TOP_COLOR, SCREEN_W , SCREEN_H + 400, BOTTOM_COLOR, z = ZOrder::BACKGROUND)
		
	# Draws album backing
		draw_quad((ALBUM_SIZE + 10) - 130, 270, Gosu::Color.argb(0xFFF7F7F7), (((ALBUM_SIZE + 10) - 130) + (ALBUM_SIZE * @display_num) + 60 + 35), 270, Gosu::Color.argb(0xFFF7F7F7), * (ALBUM_SIZE + 10) - 130, (270 + ALBUM_SIZE + 60) , Gosu::Color.argb(0xFFF7F7F7), (((ALBUM_SIZE + 10) - 130) + (ALBUM_SIZE * @display_num) + 60 + 35), (270 + ALBUM_SIZE + 60), Gosu::Color.argb(0xFFF7F7F7))
   		draw_quad((ALBUM_SIZE + 10) - 125, 275, Gosu::Color::WHITE, ((ALBUM_SIZE + 10) - 125 + (ALBUM_SIZE * @display_num) + 60 + 25), 275, Gosu::Color::WHITE, (ALBUM_SIZE + 10) - 125, (275 + ALBUM_SIZE + 50), Gosu::Color::WHITE, ((ALBUM_SIZE + 10) - 125 + (ALBUM_SIZE * @display_num) + 60 + 25), (275 + ALBUM_SIZE + 50), Gosu::Color::WHITE)
	
	# Genre title
		font = Gosu::Font.new(20)
		font.draw("Select Genre:", 75, 240, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
	end

	def draw_player()
			
		# Draws top player	
		if @song_select != nil && @SonginPlay == false
			play_img = Gosu::Image.new("assets/play.jpg")
			play_img.draw(333, 45, ZOrder::PLAYER)
		else
			play_img = Gosu::Image.new("assets/pause.jpg")
			play_img.draw(333, 45, ZOrder::PLAYER)
		end

		# Draws img & text for top player
		if @song_select != nil 
			font = Gosu::Font.new(20)
			font.draw(@song_select.name, 430, 130, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
			@albums.each do |album|
				if album.tracks.include?(@song_select)
				album.artwork.bmp.draw(350, 95, ZOrder::PLAYER, 0.24, 0.24)
				end
			end
		end
	end

	# Draws navigation buttons, WHITE or GRAY
	def draw_navigation(length)
		if @start_index == 0
			draw_triangle(50, 300, Gosu::Color::GRAY, 15, 300 + (ALBUM_SIZE / 2), Gosu::Color::GRAY, 50, 300 + ALBUM_SIZE, Gosu::Color::GRAY, ZOrder::UI)
		else
			draw_triangle(50, 300, Gosu::Color::BLACK, 15, 300 + (ALBUM_SIZE / 2), Gosu::Color::BLACK, 50, 300 + ALBUM_SIZE, Gosu::Color::BLACK, ZOrder::UI)
		end

		if @selected_genre_albums.length != 0
			current_album =  @selected_genre_albums.length
		else
			current_album =  @albums.length
		end

		if @start_index + @display_num == length || current_album < @display_num
			draw_triangle(950, 300, Gosu::Color::GRAY, 985, 300 + (ALBUM_SIZE / 2), Gosu::Color::GRAY, 950, 300 + ALBUM_SIZE, Gosu::Color::GRAY, ZOrder::UI)
		else
			draw_triangle(950, 300, Gosu::Color::BLACK, 985, 300 + (ALBUM_SIZE / 2), Gosu::Color::BLACK, 950, 300 + ALBUM_SIZE, Gosu::Color::BLACK, ZOrder::UI)
		end
	end

	# Draws genre buttons
	def draw_genre_buttons(genre_list)
		gap = 100
		genre_list.each_with_index do |album, index|
			button_gap = 100 * (index + 1) + gap
			draw_quad(button_gap, 240, Gosu::Color::WHITE, button_gap + 80, 240, Gosu::Color::WHITE, button_gap, 260, Gosu::Color::WHITE, button_gap + 80, 260, Gosu::Color::WHITE)
			font = Gosu::Font.new(20)
			font.draw(genre_list[index],button_gap + 10, 240, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		end
	
		#remove filter
		if @selected_genre_albums.length != 0
			draw_quad(800, 240, Gosu::Color::WHITE, 900, 240, Gosu::Color::WHITE, 800, 260, Gosu::Color::WHITE, 900, 260, Gosu::Color::WHITE)
			font = Gosu::Font.new(20)
			font.draw("Cancel", 820, 240, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		else
		return
		end
	end

	# Draws playlist elements
	def draw_playlist()
		#button
		draw_quad(65, 1295, Gosu::Color::GRAY, 235, 1295, Gosu::Color::GRAY, 65, 1355, Gosu::Color::GRAY, 235, 1355, Gosu::Color::GRAY)
		draw_quad(70, 1300, Gosu::Color::WHITE, 230, 1300, Gosu::Color::WHITE, 70, 1350, Gosu::Color::WHITE, 230, 1350, Gosu::Color::WHITE)
		
		if @playlist_selected == true
			font = Gosu::Font.new(20)
			font.draw("Deselect Playlist", 75, 1315, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		elsif @playlist.length > 0 
			font = Gosu::Font.new(20)
			font.draw("Custom Playlist", 75, 1315, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)
		else
			font = Gosu::Font.new(20)
			font.draw("Custom Playlist", 75, 1315, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::GRAY)
		end

		#Alert counter
		alert_img = Gosu::Image.new("assets/alert.png")
		alert_img.draw(210, 1280, ZOrder::PLAYER)
		
		font = Gosu::Font.new(30)
		font.draw(@playlist.length, 223, 1285, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::BLACK)

	end

	def draw_playhead(x)
		#draw music slider
		size = 8
		draw_quad(x, 148, Gosu::Color::GRAY, x + size, 148, Gosu::Color::GRAY, x, 148 + size, Gosu::Color::GRAY, x + size, 148 + size, Gosu::Color::GRAY, ZOrder::UI)

		#draw timer

		if @song.playing?
			current_time = Gosu.milliseconds - @start_time - 600 #delay 
			remaining_time = (@duration * 1000) - current_time
		
			remaining_seconds = (remaining_time / 1000).to_i
			remaining_minutes = remaining_seconds / 60
			remaining_seconds %= 60
		
			time_string = format('%02d:%02d', remaining_minutes, remaining_seconds)
		
			font = Gosu::Font.new(12)
			font.draw(time_string, 614, 160, ZOrder::PLAYER, 1.0, 1.0, Gosu::Color::GRAY)
		end
	end

#----------------------------------GOSU---------------------------------------------------------------------#
	def update
		if @SonginPlay == true
			current_time = Gosu.milliseconds
			elapsed_time = current_time - @start_time
			if elapsed_time >= @duration * 1000
			  @playhead_position = 640
			else
			  progress = elapsed_time.to_f / (@duration * 1000)
			  @playhead_position = 350 + (640 - 350) * progress
			end
		end

		if @SonginPlay == true && @playlist_selected == true
			if !@song.playing?
				index = @playlist.index(@song_select)
				if index < @playlist.length - 1
					@song_select = @playlist[index + 1]
					play_music(@song_select.location)
				end
			end
		end
	end

	def draw
		draw_background()
		draw_player()
		draw_playlist()
		draw_genre_buttons(@genre_list)

		# Draws tracks
		if @track_select != nil && @playlist_selected == false
			display_tracks(@track_select.tracks)
		end

		if @playlist_selected == true
			display_tracks(@playlist)
		end

		# Draws albums & nav
		if @selected_genre_albums.length != 0
			draw_albums(@selected_genre_albums, @start_index)
			draw_navigation(@selected_genre_albums.length)
		else
			draw_albums(@albums, @start_index)
			draw_navigation(@albums.length)
		end

		if @SonginPlay == true
			draw_playhead(@playhead_position)
		end

	end

 	def needs_cursor?; true; end


	def button_down(id)
		case id
	    when Gosu::MsLeft

		# Mouse position debugging
		#puts mouse_x.round().to_s 
		#puts mouse_y.round().to_s 
		
		# Album selecting click check
		if @selected_genre_albums.length != 0
			album_array = @selected_genre_albums
		else
			album_array = @albums
		end
		
		album_array[@start_index, @display_num].each_with_index do |album, index|
				if area_clicked_album((index + 1) * (ALBUM_SIZE * 1.1) - 120, 300, (index + 1) * (ALBUM_SIZE * 1.1) - 120 + ALBUM_SIZE, 300 + ALBUM_SIZE)
					puts("you clicked album: #{album.title}")
					@track_select = album
				end
		end

		
		# Track selecting click check
		if @track_select != nil && @playlist_selected == false
	    	if area_clicked_track(@track_select.tracks) == true
				play_music(@song_select.location)
			end
		elsif @playlist_selected == true
			if area_clicked_track(@playlist) == true
				play_music(@song_select.location)
			end
		end

		# Track add to playlist click check
		if @track_select != nil
	    	if area_clicked_track_add(@track_select.tracks) == true
			end
		end

		# Pause/Play click check
		if area_clicked_playbutton() == true
			if @song_select != nil && @SonginPlay == false
				@SonginPlay = true
				@song.play
			else
				@SonginPlay = false
				@song.pause
			end
		end


		# Album scrolling click check - Left
		if area_clicked_back_triangle() == true
			if @start_index > 0
				@start_index -= 1
				puts(@start_index)
			end
		end

		# Album scrolling click check - Right
		if area_clicked_forward_triangle() == true
			if @selected_genre_albums.length != 0
				if @start_index + @display_num < @selected_genre_albums.length
					@start_index += 1
					puts(@start_index)
				end
			else
				if @start_index + @display_num < @albums.length
					@start_index += 1
				end
			end
		end

		# Genre button click check
		@genre_list.each_with_index do |genre, index|
  			if area_clicked_genre(index) == true
				@start_index = 0

				# Clear selected_genre_albums
				@selected_genre_albums = []

				@albums.each do |album|
 					 if album.genre == genre
    				 	@selected_genre_albums << album
  					 end
				end
  			end
		end

		# Genre de-select button click check
		if area_clicked_de_select() == true
			#empties array
			@selected_genre_albums = []
		end

		# Playlist button click check
		if area_clicked_playlist_button() == true
			if @playlist_selected == true
				@playlist_selected = false
			else
				@playlist_selected = true
			end
		end

		# Skip/Back click check
		target = area_clicked_skiporbackbutton()
		if target != 0 && playlist_selected = true
			if @playlist.length > 0
  			index = @playlist.index(@song_select)
    		new_index = index + target
    			if new_index >= 0 && new_index < @playlist.length
    				@song_select = @playlist[new_index]
     				play_music(@song_select.location)
    			else
      				puts "Beyond playlist limits"
    			end
  			end
		end
		end
 	end
end


# Show is a method that loops through update and draw
MusicPlayerMain.new.show if __FILE__ == $0

