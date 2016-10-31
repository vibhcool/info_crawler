--[[

VLC Info Crawler Extension for VLC media player
Copyright 2016 vibhcool@BaAC

Authors: Vibhor Verma
Contact: vibhorverma1995@gmail.com

Information:

Get to know about the movie you are watching or about your music,it's album or it's artists by just clicking. Get lyrics of the songs, rating or google it. download subtitles, google about the movie, etc.   

-------------------------
Installation Instructions
-------------------------

Place this file in the corresponding folder and restart vlc or reload plugin extensions.

Linux:
  Current User: ~/.local/share/vlc/lua/extensions/
     All Users: /usr/lib/vlc/lua/extensions/

Windows:
  Current User: %APPDATA%\vlc\lua\extensions
     All Users: %ProgramFiles%\VideoLAN\VLC\lua\extensions\

Mac OS X:
  Current User: /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/extensions/
     All Users: /Applications/VLC.app/Contents/MacOS/share/lua/extensions/

------------------------------------------------------------------------------------
| PLEASE FEEL FREE TO POINT OUT THE BUGS, I WILL TRY MY BEST TO KEEP IT ERROR-FREE | 
------------------------------------------------------------------------------------ 
	 

--]]

--   CODE 

dlg = nil   

-- string to run on command line
execute_string=nil

--input string
input_string=nil

--file extension string from input string
file_format=nil

--check-box variables
goog=nil
wiki=nil
imdb=nil
srts=nil

--checks if media is music or movie
checker=nil

--checkbox for music=> title, album and artist
tit=nil
alb=nil
art=nil

--songs extra textboxes for album and artist
input_string1=nil
input_string2=nil

function descriptor()

	return {title = "Info-Crawler"}

end


function check_media1()

	
	audio_table={".3gp",".mp3",".aac",".aax",".act","aiff",".awb",".dct",".dss",".dvf","flac",".gsm",".ivs",".m4a",".m4b",".m4p",".mmf","mpc",".msv",".ogg",".oga","opus",".raw",".sln",".vox",".wav",".wma","webm"}
	
	local a=1
	
	for i=1,#audio_table
	do
		if file_format==audio_table[i] then
			a=2
		end
	end
	
	return a
	
end


function activate()
	
	input_string=vlc.input.item():name()
	s=#input_string
	file_format = input_string.sub (input_string,s-3,s)
	--checking if movie or song
	local metas = vlc.input.item():metas()
	input_string1=metas["album"]
	input_string2=metas["artist"]
	
	if input_string1==nil and input_string2==nil then 	
		
		checker=check_media1()
		
	else
		
		checker=2
		
	end
	
	build_table()
	string_process()
	create_dialog()
	
end



function deactivate()



end

function create_dialog()
    
	dlg = vlc.dialog("Content Info")
	if checker==1 then 	
		
		create_dialog1()
		
	else
		
		create_dialog2()
		
	end
	
end

--dialog for video
function create_dialog1()
    
	--title
	dlg:add_label("<b>Title of Content</b>", 1, 1, 1, 2)
    title_textview=dlg:add_text_input(input_string,2,1,4,2)
	
	--search on webpage
	dlg:add_label("<i>search in...</i>", 1, 3, 6, 1)
    goog=dlg:add_check_box("google",true,2,4,3,1)
	wiki=dlg:add_check_box("wiki",false,2,5,3,1)
	imdb=dlg:add_check_box("imdb",false,2,6,3,1)
	srts=dlg:add_check_box("srts",false,2,7,3,1)
	
	--buttons
	dlg:add_button("close",vlc.deactivate,1,8,1,1)
	dlg:add_button("search",function() search() end,3,8,2,1)
	
end

--dialog for music
function create_dialog2()
    
	--title
	tit=dlg:add_check_box("Title",true, 1, 1, 1, 2)
    title_textview=dlg:add_text_input(input_string,3,1,4,2)
	alb=dlg:add_check_box("album",false, 1, 3, 1, 2)
    album_textview=dlg:add_text_input(input_string1,3,3,4,2)
	art=dlg:add_check_box("artists",false, 1, 5, 1, 2)
    artist_textview=dlg:add_text_input(input_string2,3,5,4,2)
	
	--search on webpage
	dlg:add_label("<i>search in...</i>", 1, 7, 6, 1)
    goog=dlg:add_check_box("google",true,2,7,3,1)
	wiki=dlg:add_check_box("wiki",false,2,8,3,1)
	imdb=dlg:add_check_box("songs rating",false,2,9,3,1)
	srts=dlg:add_check_box("lyrics",false,2,10,3,1)
	
	--buttons
	dlg:add_button("close",vlc.deactivate,1,11,1,1)
	dlg:add_button("search",function() search() end,3,11,2,1)
	
end

function search()

	open_cmd=nil

	-- string to run on command line
	execute_string=nil
	goog_string=nil
	wiki_string=nil
	imdb_string=nil
	srts_string=nil



	
	if checker==2 then
		input_string=""
		
		local aa=title_textview:get_text()
		
		if tit:get_checked()==true then
			
			input_string=input_string.." "..aa
			
	
		end
		if alb:get_checked()==true then
			input_string=input_string.." "..album_textview:get_text()
		end
		if art:get_checked()==true then 
			input_string=input_string.." "..artist_textview:get_text()
		end
	else
		input_string=title_textview:get_text()
	end
	
	string_process()
	title_textview:set_text(input_string)
	
	--google link build
	goog_string=input_string.gsub(input_string," ","+")
	
	--wiki link build
	wiki_string=input_string.gsub(input_string," ","+")
	
	--imdb link build
	if checker==1 then
		imdb_string=input_string.gsub(input_string," ","+")
	else
		allm_string=input_string.gsub(input_string," ","%%20")
	end
	
	--srts link build
	if checker==1 then
		srts_string=input_string.gsub(input_string," ","+")
	else
		azly_string=input_string.gsub(input_string," ","+")
	end 
	
	open_url()
	
end

function string_process()
	
	v=#common_table
		
	for i=1,v  do
		input_string=input_string.gsub(input_string,common_table[i]," ")
		input_string=input_string.gsub(input_string,"  "," ")
	end
	
	--if(input_string[v-1]==" ")
	--input_string = input_string.sub (input_string,1,v-2)
		
	
end

function open_url()
    if not open_cmd then
        if package.config:sub(1,1) == '\\' then -- windows
            if goog:get_checked()==true then
				
				win_execute("https://www.google.com/search?q="..goog_string)
			end
			if wiki:get_checked()==true then
				win_execute("https://en.wikipedia.org/w/index.php?search="..wiki_string)
				--vlc.volume.set(256)
			end
			if imdb:get_checked()==true then
				--vlc.volume.set(256)
				if checker==1 then
					win_execute("http://www.imdb.com/find?q="..imdb_string)
					
				else 
					win_execute("http://www.allmusic.com/search/all/"..allm_string)
				end
			end
			if srts:get_checked()==true then
				if checker==1 then
					win_execute("http://subscene.com/subtitles/title?q="..srts_string)
					--vlc.volume.set(256)
				else 
					win_execute("http://search.azlyrics.com/search.php?q="..azly_string)
				end
			end
			win_execute_end()
        -- the only systems left should understand uname...
        elseif (io.popen("uname -s"):read'*a') == "Darwin" then -- OSX/Darwin ? (I can not test.)
                os.execute(string.format('open "%s"', url))
            
        else -- that ought to only leave Linux
            os.execute(string.format('xdg-open "%s"', url))
            
        end
    end

end

function win_execute(url)
	if execute_string~=nil then
		execute_string=execute_string.." & start "..url
	else	
		execute_string="start "..url
	end
	
end

function win_execute_end()
	
	execute_string=execute_string.."& exit"
	os.execute(execute_string)
	--vlc.deactivate()

end

--add trailer

function joinTable(t1,t2)
 
	
	for k,v in pairs(t2) do
		table.insert(t1,v)
		vlc.volume.set(256)
	end 
 
	return t1
   
end

function build_table()

	common_table={"HIGH","Lyrics","FULL","AUDIO",".Info",".Net",".SE",".se",".CC",".cc",".net",".com",".Com","CoM","T-Series","Official","Video","OFFICIAL","www","WWW","wWw"}
	
	--removing audio strings
	local audio_table={"Songs","DjPunjab","DJMaza","DownloadMing","rKmania","SongsLover","SpreadMp3","MirchiWap",".pk",".PK","190Kbps","254Kbps","mp3","Mp3",".wav",".wma",".aac"}
	
	--removing movie strings
	local movie_table={"BrRip","hd","HD","mHD","AC3","DDR","Blu-Ray","blu-ray","DvDRip","BluRay","Dual Audio","dual audio","YIFY","720p","1080p","x264",".avi",".mp4",".mkv",".wmv",".vob",".mov",".flv",".f4v",".f4p",".f4a",".f4b",".nsv",".roq",".mxf",".3g2",".svi",".m4v","webm",".vob","gifv","rmvb",".yuv",".asf",".m4p",".mpg",".mp2",".mpe",".mpv",".mpg","mpeg",".m2v"}
	
	--removing symbols
	local sym_table={"%(","%)","%.","%%","+","-","%*","%?","%[","%^","%$","!","@","#","\\",";",":","\\","/","|","_"}
	
	
	--input string filter
	common_table=joinTable(common_table,sym_table)
	
	if checker==1 then
		
		common_table=joinTable(common_table,movie_table)
				
	else
		
		common_table=joinTable(common_table,audio_table)
		
	end

end

--[[
function check_media()

	local a=2
	local s=#input_string
	local fl=input_string.sub(input_string,s-3,s)
	local file_format_table={".avi",".mp4",".mkv",".wmv",".vob",".mov",".flv",".f4v",".f4p",".f4a",".f4b",".nsv",".roq",".mxf",".3g2",".svi",".m4v","webm",".vob","gifv","rmvb",".yuv",".asf",".m4p",".mpg",".mp2",".mpe",".mpv",".mpg","mpeg",".m2v"}
	for i=1,#file_format_table 
	do
		if fl==file_format_table[i] then
			a=1
		end
	end
	
	return a
	
end

--]]