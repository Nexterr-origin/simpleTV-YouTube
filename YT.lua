-- видеоскрипт для сайта https://www.youtube.com (28/3/21)
-- https://github.com/Nexterr-origin/simpleTV-YouTube
--[[
	Copyright © 2017-2021 Nexterr
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
		http://www.apache.org/licenses/LICENSE-2.0
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]
-- UTF-8 without BOM
-- поиск из окна "Открыть URL" (Ctrl+N), префиксы: - (видео), -- (плейлисты), --- (каналы), -+ (прямые трансляции)
-- авторизаця: файл формата "Netscape HTTP Cookie File" - cookies.txt поместить в папку 'work'
-- показать на OSD плейлист / выбор качества: Ctrl+M
--------------------------------------------------------------------
local infoInFile = false
--------------------------------------------------------------------
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^[%p%a%s]*https?://[%a.]*youtu[.combe]')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://[%w.]*hooktube%.com')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://[%w.]*invidio[%a]*%.')
			and not m_simpleTV.Control.CurrentAddress:match('^[%p%a%s]*https?://y2u%.be')
			and not m_simpleTV.Control.CurrentAddress_UTF8:match('^%-')
		then
		 return
		end
	if infoInFile then
		infoInFile = os.clock()
	end
	local inAdr
	if m_simpleTV.Control.CurrentAddress_UTF8:match('^%-') then
		inAdr = m_simpleTV.Control.CurrentAddress_UTF8
	else
		inAdr = m_simpleTV.Control.CurrentAddress
	end
	local urlAdr = inAdr
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.YT then
		m_simpleTV.User.YT = {}
	end
	if not m_simpleTV.User.YT.VersionCheck then
		local _, strVer = m_simpleTV.Common.GetVersion()
		local vlcVer = m_simpleTV.Common.GetVlcVersion()
		if not (strVer:match('b12%.7%.7 test')
			or strVer:match('b12%.7%.6'))
			or vlcVer < 3000
		then
			local msg = 'simpleTV need 0.5.0 b12.7.6 (vlc 3.0.11)'
			local link = 'https://mega.nz/folder/G74EBKDQ#77wUEcj-IfrmghM8QVti3w/folder/C2o21LZL'
			m_simpleTV.Interface.MessageBox(msg, 'YouTube', 0x10)
			m_simpleTV.Interface.OpenLink(link)
		 return
		end
		m_simpleTV.User.YT.VersionCheck = true
	end
	htmlEntities = require 'htmlEntities'
	require 'lfs'
	require 'asynPlsLoaderHelper'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.YT then
		m_simpleTV.User.YT = {}
	end
	if not m_simpleTV.User.YT.logoPicFromDisk then
		local path = m_simpleTV.Common.GetMainPath(1) .. 'Channel/'
		local f = path .. 'logo/Icons/YT_logo.png'
		local size = lfs.attributes(f, 'size')
		if not size then
			lfs.mkdir(path)
			local pathL = path .. 'logo/'
			lfs.mkdir(pathL)
			local pathI = pathL .. 'Icons/'
			lfs.mkdir(pathI)
			local fhandle = io.open(f, 'w+b')
			if fhandle then
				local logo = 'iVBORw0KGgoAAAANSUhEUgAAAyAAAAJYCAMAAACtqHJCAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMAUExURQAAAAEAAgECAAICAgEBBAQAAAUAAgUCAAUCAwUCBAUFBQkAAQkAAggCAQ0AAAwAAg4CAQwCAgkJCQ4ODhIBAREBAhICARACAxABBBUAARUAAhcCARkAAR4BAR4AAhERERQUFBkZGR0dHSABACEAAiUAACQBAikBAi8CAzEBATIAAjQBATQBAjsBAj4BAj4CACEhISUlJSoqKi0tLTIyMjU1NTk5OT09PUAAAUAAA0QAAEUAAkUCAksBAk8BAU0BBFIBAVICBFYAAFQBAlUCAFkAAFgBA1wAAV4BBGABAGAAAmICAmUBAWoBAW0BAW8BAnEAAXEAAnQAAXcBAnUCA3gBAH0BAUBAQEVFRUpKSk1NTVFRUVZWVllZWV5eXmJiYmVlZWlpaW1tbXFxcXV1dXl5eX19fYIBA4MCAoUBAoQBBIkAAYgAAosBBI0BAYwCBpEBApYBAZUBBJ0BAqABAqUBAaQAAqkBAakBBK8BAbEBA7QBAboAALoBA7oCAbsCArkBBL4BAbwBAr0CA8YBAckBAs0AAtEAANABAtECA9YBAdcBAtkAAdwAAeEAAOUAAeUCBukAAO0AAO0BAuwCAe8CA+8BBPABAfYAAPUBAvQCAfoAAPoBAvoCAfoCAvsBBP0AAP0AAvwCAPwCAv0CBPwEA/wFBfwKCv0OEP0QEf4VFfwWGfsYGfwaGv0eHv4fIP0gH/slJf4gIPwlJPwoKv0vMPwxMfw0Ofw+PvxOUPxRU/xYVf5bXfxcXf1qavt7e/15fPx/fIGBgYWFhYiIiI2NjZGRkZWVlZmZmZycnKGhoaampqmpqa2trbKysrS0tLm5ub29vfuDgf2RkfyVk/yWlvyYl/2jo/2kpPyqqfu7u/66uv7Bv8HBwcbGxsnJyc3NzdDQ0NXV1dnZ2d3d3fzDwfzFw/zJxvvPzvzR0P7d2/zc3OHh4eXl5enp6e3t7f3k4f3m5v3s7P3w7fHx8fX19fzz8fz29f349vn5+fr++/v+/P75+f39+/7+/gAAAKO0mi0AAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAPo0lEQVR4Xu3de5yc1V0H4BkG0rog6K54wcomMQWpbQ2BEIVWsYqX2lZayzXcCVEsYpG2WLHW1gZQCzGgQgy32SDWG2rVipdWJUBKEm7eqyYhWbyWJIrZ0pF0Pr6X3/vOzO5mMrvZjWnmeT5c5py5vPnjfPOe877nnLcCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACHvmr2T/Zv8t9E9mKCqM7eHv+R6oQaOGSkocgc85ULTnjNN37T6ad/53ef9ea3v/3ss9/xQ+961zWFc85OfN9ZZ33X6Wd8y0mvffWC4449IvtWmhkJ4VB15PGv+Y63XXP9T9182+rVd6+5Z8399ftDvV6+TI1ExUjy75r716y5+67Vd/z8h9577Tu/53ULvqIWvwaHjGp1znHf+4GVd2XNf7+s+cUV7zy+WktPJwebwaEwEBXQo+orz111/wPRxvdTfe2vvOdra7XD46cPHo/sDqdGBfRowYr62rS/NCPq9bUr39CRj9pwoa3/NRBVw0NR0bvB+OYkupwd1jXD4qiAXlSrJ/5CxxBjBqz+tvax+uBoIzd2StQkrmiM5ZVPREXvnsi/OJkL4yOTeDTyISBMyZyv+rmRu2fs/JEbuePE+PXMxmiazUuiIvF0VDW7tOm92BDfnISAMNNqP1Kvj6yNlj1D1t6z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'
				logo = decode64(logo)
				fhandle:write(logo)
				fhandle:close()
			end
		end
		m_simpleTV.User.YT.logoPicFromDisk = f
	end
	if not m_simpleTV.User.YT.playPicFromDisk then
		local path = m_simpleTV.Common.GetMainPath(1) .. 'Channel/'
		local f = path .. 'logo/Icons/YT_play.png'
		local size = lfs.attributes(f, 'size')
		if not size then
			lfs.mkdir(path)
			local pathL = path .. 'logo/'
			lfs.mkdir(pathL)
			local pathI = pathL .. 'Icons/'
			lfs.mkdir(pathI)
			local fhandle = io.open(f, 'w+b')
			if fhandle then
				local logo = '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'
				logo = decode64(logo)
				fhandle:write(logo)
				fhandle:close()
			end
		end
		m_simpleTV.User.YT.playPicFromDisk = f
	end
	local function inAdr_clean(inAdr)
		if not m_simpleTV.Common.isUTF8(inAdr) then
			inAdr = m_simpleTV.Common.multiByteToUTF8(inAdr)
		end
		inAdr = inAdr:gsub('^.-https?://', 'https://')
		inAdr = inAdr:gsub('[\'"%[%]()]+.-$', '')
		inAdr = m_simpleTV.Common.fromPercentEncoding(inAdr)
		inAdr = inAdr:gsub('[\'"]+.-$', '')
		inAdr = inAdr:gsub('amp;', '')
		inAdr = inAdr:gsub('\\', '/')
		inAdr = inAdr:gsub('$OPT:.-$', '')
		inAdr = inAdr:gsub('disable_polymer=%w+', '')
		inAdr = inAdr:gsub('%?pbjreload=.-$', '')
		inAdr = inAdr:gsub('%?action=%w+', '')
		inAdr = inAdr:gsub('%?sub_confirmation=%w+', '')
		inAdr = inAdr:gsub('flow=list', '')
		inAdr = inAdr:gsub('no_autoplay=%w+', '')
		inAdr = inAdr:gsub('start_radio=%d+', '')
		inAdr = inAdr:gsub('time_continue=', 't=')
		inAdr = inAdr:gsub('/videoseries', '/playlist')
		inAdr = inAdr:gsub('list_id=', 'list=')
		inAdr = inAdr:gsub('/feed%?', '?')
		inAdr = inAdr:gsub('//gaming%.', '//www.')
		inAdr = inAdr:gsub('/featured%?*', '')
		inAdr = inAdr:gsub('&nohtml5=%w+', '')
		inAdr = inAdr:gsub('&feature=[^&]*', '')
		inAdr = inAdr:gsub('&playnext=%w+', '')
		inAdr = inAdr:gsub('/tv%#/.-%?', '/watch?')
		inAdr = inAdr:gsub('&resume', '')
		inAdr = inAdr:gsub('&spf=%w+', '')
		inAdr = inAdr:gsub('/live%?.-$', '/live')
		inAdr = inAdr:gsub('%#t=', '&t=')
		inAdr = inAdr:gsub('&t=0s', '')
		inAdr = inAdr:gsub('&+', '&')
		inAdr = inAdr:gsub('%?+', '?')
		inAdr = inAdr:gsub('[&?/]+$', '')
		inAdr = inAdr:gsub('%s+', '')
		inAdr = inAdr:gsub('/([?=&])', '%1')
		if not inAdr:match('^https://[%a.]*youtu[.combe]') and not inAdr:match('^https://y[2out]*u%.be/') then
			inAdr = inAdr:gsub('^https://[^/]+(/.+)', 'https://www.youtube.com%1')
		end
		inAdr = inAdr:gsub('//youtube%.', '//www.youtube.')
		local id = inAdr:match('/playlist%?list=RD([^&]*)')
		if id and #id == 11 then
			inAdr = inAdr:gsub('/playlist%?list=RD[^&]*', '/watch?v='.. id .. '&list=RD' .. id)
		end
	 return inAdr
	end
	local function SetBackground(pic, use)
		if m_simpleTV.Control.MainMode == 0 then
			use = use or 3
			pic = pic or ''
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = pic, TypeBackColor = 0, UseLogo = use, Once = 1})
		end
	end
	local function infoPanelCheck()
		local infoPanel = tonumber(m_simpleTV.Config.GetValue('mainOsd/showTimeInfoPanel', 'simpleTVConfig') or 0)
			if infoPanel > 0 then
			 return true
			end
	 return false
	end
	if inAdr:match('https?://')
		and not inAdr:match('&is%a+=%a+')
	then
		inAdr = inAdr_clean(inAdr)
	end
	if not (inAdr:match('/user/')
		or inAdr:match('/channel/')
		or inAdr:match('/c/')
		or inAdr:match('&numVideo=')
		or inAdr:match('youtube%.com/%w+$')
		or inAdr:match('youtube%.com/[^/]+/playlists')
		or inAdr:match('&isRestart=true')
		or inAdr:match('/youtubei/')
		or inAdr:match('/watch_videos')
		)
	then
		if inAdr:match('&isPlst=')
			or inAdr:match('&isLogo=false')
			or m_simpleTV.Control.ChannelID ~= 268435455
		then
			SetBackground()
		else
			if not inAdr:match('&isPlstsCh=true') then
				SetBackground(m_simpleTV.User.YT.logoPicFromDisk, 3)
			end
		end
	elseif inAdr:match('/videos') then
		SetBackground(m_simpleTV.User.YT.logoPicFromDisk, 3)
	elseif inAdr:match('/channel/') and inAdr:match('&isLogo=false') then
		SetBackground()
	end
	if not (m_simpleTV.Control.GetState() == 3 and m_simpleTV.User.YT.isVideo == false) then
		m_simpleTV.User.YT.isVideo = true
	end
	if not m_simpleTV.User.YT.Lng then
		m_simpleTV.User.YT.Lng = {}
		if m_simpleTV.Interface.GetLanguage() == 'ru' then
			m_simpleTV.User.YT.Lng.adaptiv = 'адаптивное'
			m_simpleTV.User.YT.Lng.desc = 'описание'
			m_simpleTV.User.YT.Lng.qlty = 'качество'
			m_simpleTV.User.YT.Lng.savePlstFolder = 'сохраненые плейлисты'
			m_simpleTV.User.YT.Lng.savePlst_1 = 'плейлист сохранен в файл'
			m_simpleTV.User.YT.Lng.savePlst_2 = 'в папку'
			m_simpleTV.User.YT.Lng.savePlst_3 = 'невозможно сохранить плейлист'
			m_simpleTV.User.YT.Lng.sub = 'субтитры'
			m_simpleTV.User.YT.Lng.subTr = 'перевод'
			m_simpleTV.User.YT.Lng.preview = 'предосмотр'
			m_simpleTV.User.YT.Lng.audio = 'аудио'
			m_simpleTV.User.YT.Lng.noAudio = 'нет аудио'
			m_simpleTV.User.YT.Lng.plst = 'плейлист'
			m_simpleTV.User.YT.Lng.error = 'ошибка'
			m_simpleTV.User.YT.Lng.live = 'прямая трансляция'
			m_simpleTV.User.YT.Lng.upLoadOnCh = 'загружено на канал'
			m_simpleTV.User.YT.Lng.loading = 'загрузка'
			m_simpleTV.User.YT.Lng.videoNotAvail = 'видео не доступно'
			m_simpleTV.User.YT.Lng.videoNotExst = 'видео не существует'
			m_simpleTV.User.YT.Lng.page = 'стр.'
			m_simpleTV.User.YT.Lng.hl = 'ru_RU'
			m_simpleTV.User.YT.Lng.hl_sub = 'ru'
			m_simpleTV.User.YT.Lng.camera = 'вид с видеокамеры'
			m_simpleTV.User.YT.Lng.camera_plst_title = 'список видеокамер'
			m_simpleTV.User.YT.Lng.channel = 'канал'
			m_simpleTV.User.YT.Lng.video = 'видео'
			m_simpleTV.User.YT.Lng.search = 'поиск'
			m_simpleTV.User.YT.Lng.notFound = 'не найдено'
			m_simpleTV.User.YT.Lng.started = 'начало в'
			m_simpleTV.User.YT.Lng.published = 'опубликовано'
			m_simpleTV.User.YT.Lng.duration = 'продолжительность'
			m_simpleTV.User.YT.Lng.relatedVideos = 'похожие видео'
			m_simpleTV.User.YT.Lng.link = 'открыть в браузере'
			m_simpleTV.User.YT.Lng.noCookies = 'ТРЕБУЕТСЯ ВХОД: используйте "cookies файл" для авторизации'
			m_simpleTV.User.YT.Lng.chapter = 'главы'
		elseif m_simpleTV.Interface.GetLanguage() == 'pt' then
			m_simpleTV.User.YT.Lng.adaptiv = 'adaptável'
			m_simpleTV.User.YT.Lng.desc = 'descrição'
			m_simpleTV.User.YT.Lng.qlty = 'qualidade'
			m_simpleTV.User.YT.Lng.savePlstFolder = 'playlists salvas'
			m_simpleTV.User.YT.Lng.savePlst_1 = 'lista de reprodução salva em arquivo'
			m_simpleTV.User.YT.Lng.savePlst_2 = 'para pasta'
			m_simpleTV.User.YT.Lng.savePlst_3 = 'não é possível salvar a playlist'
			m_simpleTV.User.YT.Lng.sub = 'legendas'
			m_simpleTV.User.YT.Lng.subTr = 'traduzido'
			m_simpleTV.User.YT.Lng.preview = 'preview'
			m_simpleTV.User.YT.Lng.audio = 'áudio'
			m_simpleTV.User.YT.Lng.noAudio = 'sem áudio'
			m_simpleTV.User.YT.Lng.plst = 'lista de reprodução'
			m_simpleTV.User.YT.Lng.error = 'erro'
			m_simpleTV.User.YT.Lng.live = 'em direto'
			m_simpleTV.User.YT.Lng.upLoadOnCh = 'uploads do canal'
			m_simpleTV.User.YT.Lng.loading = 'a carregar'
			m_simpleTV.User.YT.Lng.videoNotAvail = 'vídeo não disponível'
			m_simpleTV.User.YT.Lng.videoNotExst = 'vídeo não existe'
			m_simpleTV.User.YT.Lng.page = 'página'
			m_simpleTV.User.YT.Lng.hl = 'pt_PT'
			m_simpleTV.User.YT.Lng.hl_sub = 'pt'
			m_simpleTV.User.YT.Lng.camera = 'visão da câmera'
			m_simpleTV.User.YT.Lng.camera_plst_title = 'álternar câmera'
			m_simpleTV.User.YT.Lng.channel = 'chanel'
			m_simpleTV.User.YT.Lng.video = 'vídeo'
			m_simpleTV.User.YT.Lng.search = 'procurar'
			m_simpleTV.User.YT.Lng.notFound = 'não encontrado'
			m_simpleTV.User.YT.Lng.started = 'started'
			m_simpleTV.User.YT.Lng.published = 'published'
			m_simpleTV.User.YT.Lng.duration = 'duration'
			m_simpleTV.User.YT.Lng.relatedVideos = 'vídeos relacionados'
			m_simpleTV.User.YT.Lng.link = 'abra no navegador'
			m_simpleTV.User.YT.Lng.noCookies = 'LOGIN NECESSÁRIO: usar "cookies file" para autorização'
			m_simpleTV.User.YT.Lng.chapter = 'chapters'
		elseif m_simpleTV.Interface.GetLanguage() == 'vi' then
			m_simpleTV.User.YT.Lng.adaptiv = 'Thích nghi'
			m_simpleTV.User.YT.Lng.desc = 'Sự miêu tả'
			m_simpleTV.User.YT.Lng.qlty = 'Chất lượng'
			m_simpleTV.User.YT.Lng.savePlstFolder = 'Đã lưu danh sách phát'
			m_simpleTV.User.YT.Lng.savePlst_1 = 'Danh sách phát được lưu thành file'
			m_simpleTV.User.YT.Lng.savePlst_2 = 'vào thư mục'
			m_simpleTV.User.YT.Lng.savePlst_3 = 'Không thể lưu'
			m_simpleTV.User.YT.Lng.sub = 'Phụ đề'
			m_simpleTV.User.YT.Lng.subTr = 'Google dịch'
			m_simpleTV.User.YT.Lng.preview = 'Xem lại'
			m_simpleTV.User.YT.Lng.audio = 'Âm thanh'
			m_simpleTV.User.YT.Lng.noAudio = 'Không có âm thanh'
			m_simpleTV.User.YT.Lng.plst = 'Danh sách phát'
			m_simpleTV.User.YT.Lng.error = 'Lỗi'
			m_simpleTV.User.YT.Lng.live = 'Trực tiếp'
			m_simpleTV.User.YT.Lng.upLoadOnCh = 'Kênh'
			m_simpleTV.User.YT.Lng.loading = 'Đang tải'
			m_simpleTV.User.YT.Lng.videoNotAvail = 'Video không có sẵn'
			m_simpleTV.User.YT.Lng.videoNotExst = 'Video không tồn tại'
			m_simpleTV.User.YT.Lng.page = 'Trang.'
			m_simpleTV.User.YT.Lng.hl = 'vi'
			m_simpleTV.User.YT.Lng.hl_sub = 'vi'
			m_simpleTV.User.YT.Lng.camera = 'Xem camera'
			m_simpleTV.User.YT.Lng.camera_plst_title = 'Đổi camera'
			m_simpleTV.User.YT.Lng.channel = 'Kênh'
			m_simpleTV.User.YT.Lng.video = 'Video'
			m_simpleTV.User.YT.Lng.search = 'Tìm kiếm'
			m_simpleTV.User.YT.Lng.notFound = 'Không tìm thấy'
			m_simpleTV.User.YT.Lng.started = 'Bắt đầu'
			m_simpleTV.User.YT.Lng.published = 'Xuất bản'
			m_simpleTV.User.YT.Lng.duration = 'Thời lượng'
			m_simpleTV.User.YT.Lng.relatedVideos = 'Video liên quan'
			m_simpleTV.User.YT.Lng.link = 'Mở trong trình duyệt'
			m_simpleTV.User.YT.Lng.noCookies = 'YÊU CẦU ĐĂNG NHẬP: sử dụng "cookies file" để ủy quyền'
			m_simpleTV.User.YT.Lng.chapter = 'Chươngi'
		elseif m_simpleTV.Interface.GetLanguage() == 'pl' then
			m_simpleTV.User.YT.Lng.adaptiv = 'adaptacyjny'
			m_simpleTV.User.YT.Lng.desc = 'opis'
			m_simpleTV.User.YT.Lng.qlty = 'jakość'
			m_simpleTV.User.YT.Lng.savePlstFolder = 'zapisane listy odtwarzania'
			m_simpleTV.User.YT.Lng.savePlst_1 = 'lista odtwarzania zapisana do pliku'
			m_simpleTV.User.YT.Lng.savePlst_2 = 'do folderu'
			m_simpleTV.User.YT.Lng.savePlst_3 = 'nie można zapisać listy odtwarzania'
			m_simpleTV.User.YT.Lng.sub = 'napisy na filmie obcojęzycznym'
			m_simpleTV.User.YT.Lng.subTr = 'przetłumaczony'
			m_simpleTV.User.YT.Lng.preview = 'zapowiedź'
			m_simpleTV.User.YT.Lng.audio = 'audio'
			m_simpleTV.User.YT.Lng.noAudio = 'brak dźwięku'
			m_simpleTV.User.YT.Lng.plst = 'lista odtwarzania'
			m_simpleTV.User.YT.Lng.error = 'błąd'
			m_simpleTV.User.YT.Lng.live = 'relacja na żywo'
			m_simpleTV.User.YT.Lng.upLoadOnCh = 'przesłane z kanału'
			m_simpleTV.User.YT.Lng.loading = 'Ładowanie'
			m_simpleTV.User.YT.Lng.videoNotAvail = 'video not available'
			m_simpleTV.User.YT.Lng.videoNotExst = 'wideo niedostępne'
			m_simpleTV.User.YT.Lng.page = 'strona'
			m_simpleTV.User.YT.Lng.hl = 'pl'
			m_simpleTV.User.YT.Lng.hl_sub = 'pl'
			m_simpleTV.User.YT.Lng.camera = 'widok z kamery'
			m_simpleTV.User.YT.Lng.camera_plst_title = 'przełącz aparat'
			m_simpleTV.User.YT.Lng.channel = 'kanał'
			m_simpleTV.User.YT.Lng.video = 'wideo'
			m_simpleTV.User.YT.Lng.search = 'Szukaj'
			m_simpleTV.User.YT.Lng.notFound = 'nie znaleziono'
			m_simpleTV.User.YT.Lng.started = 'started'
			m_simpleTV.User.YT.Lng.published = 'Rozpoczęty'
			m_simpleTV.User.YT.Lng.duration = 'Trwanie'
			m_simpleTV.User.YT.Lng.relatedVideos = 'powiązane wideo'
			m_simpleTV.User.YT.Lng.link = 'Otwórz w przeglądarce'
			m_simpleTV.User.YT.Lng.noCookies = 'WYMAGANE LOGOWANIE: użyj „pliku cookie” do autoryzacji'
			m_simpleTV.User.YT.Lng.chapter = 'rozdziałi'
		else
			m_simpleTV.User.YT.Lng.adaptiv = 'adaptive'
			m_simpleTV.User.YT.Lng.desc = 'description'
			m_simpleTV.User.YT.Lng.qlty = 'quality'
			m_simpleTV.User.YT.Lng.savePlstFolder = 'saved playlists'
			m_simpleTV.User.YT.Lng.savePlst_1 = 'playlist saved to file'
			m_simpleTV.User.YT.Lng.savePlst_2 = 'to folder'
			m_simpleTV.User.YT.Lng.savePlst_3 = 'unable to save playlist'
			m_simpleTV.User.YT.Lng.sub = 'subtitles'
			m_simpleTV.User.YT.Lng.subTr = 'translated'
			m_simpleTV.User.YT.Lng.preview = 'preview'
			m_simpleTV.User.YT.Lng.audio = 'audio'
			m_simpleTV.User.YT.Lng.noAudio = 'no audio'
			m_simpleTV.User.YT.Lng.plst = 'playlist'
			m_simpleTV.User.YT.Lng.error = 'error'
			m_simpleTV.User.YT.Lng.live = 'live'
			m_simpleTV.User.YT.Lng.upLoadOnCh = 'uploads from channel'
			m_simpleTV.User.YT.Lng.loading = 'loading'
			m_simpleTV.User.YT.Lng.videoNotAvail = 'video not available'
			m_simpleTV.User.YT.Lng.videoNotExst = 'video does not exist'
			m_simpleTV.User.YT.Lng.page = 'page'
			m_simpleTV.User.YT.Lng.hl = 'en_US'
			m_simpleTV.User.YT.Lng.hl_sub = 'en'
			m_simpleTV.User.YT.Lng.camera = 'camera view'
			m_simpleTV.User.YT.Lng.camera_plst_title = 'switch camera'
			m_simpleTV.User.YT.Lng.channel = 'channel'
			m_simpleTV.User.YT.Lng.video = 'video'
			m_simpleTV.User.YT.Lng.search = 'search'
			m_simpleTV.User.YT.Lng.notFound = 'not found'
			m_simpleTV.User.YT.Lng.started = 'started'
			m_simpleTV.User.YT.Lng.published = 'published'
			m_simpleTV.User.YT.Lng.duration = 'duration'
			m_simpleTV.User.YT.Lng.relatedVideos = 'related videos'
			m_simpleTV.User.YT.Lng.link = 'open in browser'
			m_simpleTV.User.YT.Lng.noCookies = 'LOGIN REQUIRED: use "cookies file" for authorization'
			m_simpleTV.User.YT.Lng.chapter = 'chapters'
		end
	end
	if not m_simpleTV.User.YT.OpenUrlHelpCheck then
		if m_simpleTV.PlayList.GetOpenUrlHelp() == '' then
			local help_text = '<html><body><h3>🔎 ' .. m_simpleTV.User.YT.Lng.search .. '</h3><p></p><p><strong>YouTube</strong></p><table border="1"><tbody><tr><td>&nbsp;<strong>- ' .. m_simpleTV.User.YT.Lng.video .. '</strong>&nbsp;</td><td>&nbsp;<strong>-- ' .. m_simpleTV.User.YT.Lng.plst .. '</strong>&nbsp;</td></tr><tr><td>&nbsp;<strong>--- ' .. m_simpleTV.User.YT.Lng.channel .. '</strong>&nbsp;</td><td>&nbsp;<strong>-+ ' .. m_simpleTV.User.YT.Lng.live .. '</strong>&nbsp;</td></tr></tbody></table></body></html>'
			m_simpleTV.PlayList.SetOpenUrlHelp(help_text)
		end
		m_simpleTV.User.YT.OpenUrlHelpCheck = true
	end
	if not m_simpleTV.User.YT.cookies then
			local function cookiesFromFile()
				local f = string.format('%scookies.txt', m_simpleTV.Common.GetMainPath(1))
				local fhandle = io.open(f, 'r')
					if not fhandle then return end
				local YT_Cookies = {'SID', 'HSID', 'SSID', 'SAPISID', 'APISID'}
				local cookie_SAPISID
				local t = {}
					for line in fhandle:lines() do
						local name, val = line:match('youtube%.com.+%s(%S+)%s+(%S+)')
						if name and val then
							for i = 1, #YT_Cookies do
								if name == YT_Cookies[i] then
									t[#t + 1] = string.format('%s=%s', name, val)
									if not cookie_SAPISID and name == 'SAPISID' then
										cookie_SAPISID = val
									end
								 break
								end
							end
						end
						if #t == 5 then break end
					end
				fhandle:close()
					if #t < 5 then return end
				m_simpleTV.User.YT.isAuth = cookie_SAPISID
			 return table.concat(t, ';')
			end
		m_simpleTV.User.YT.cookies = string.format('%s;PREF=hl=%s;', (cookiesFromFile() or ''), m_simpleTV.User.YT.Lng.hl)
	end
	if not m_simpleTV.User.YT.PlstsCh then
		m_simpleTV.User.YT.PlstsCh = {}
	end
	if not m_simpleTV.User.YT.PlstsCh.Urls then
		m_simpleTV.User.YT.PlstsCh.Urls = {}
	end
	if not m_simpleTV.User.YT.Plst then
		m_simpleTV.User.YT.Plst = {}
	end
	if not m_simpleTV.User.YT.qlty then
		m_simpleTV.User.YT.qlty = tonumber(m_simpleTV.Config.GetValue('YT_qlty') or '1080')
	end
	if not m_simpleTV.User.YT.qlty_live then
		m_simpleTV.User.YT.qlty_live = tonumber(m_simpleTV.Config.GetValue('YT_qlty_live') or '1080')
	end
	if m_simpleTV.User.YT.isPlstsCh then
		m_simpleTV.User.YT.isPlstsCh = nil
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 14000)
	m_simpleTV.User.YT.DelayedAddress = nil
	m_simpleTV.User.YT.isChapters = false
	local inf0, inf01
	local isInfoPanel = infoPanelCheck()
	local videoId = inAdr:match('[?&/]v[=/](.+)')
				or inAdr:match('/embed/(.+)')
				or inAdr:match('/watch/(.+)')
				or inAdr:match('y[2out]*u%.be/(.+)')
				or inAdr:match('video_id=(.+)')
				or ''
	videoId = videoId:sub(1, 11)
	local function ShowMsg(msg, reason, qlty)
		if reason then
			msg = msg .. '\n' .. reason
		end
		local t = {}
			for m in msg:gmatch('[^\n]+') do
				t[#t + 1] = m
			end
			for j = #t, 1, -1 do
				local imageParam, color, id
				local once = true
				if j == 1 then
					imageParam = 'vSizeFactor="0.5" src="https://s.ytimg.com/yts/img/favicon_48-vfl1s0rGh.png"'
					color = ARGB(255, 128, 128, 255)
					id = 'channelName'
				else
					color = ARGB(255, 139, 135, 135)
					id = j - 1
				end
				if qlty then
					once = false
					color = ARGB(255, 139, 135, 135)
					imageParam = 'src=""'
					id = 'channelName'
				end
				m_simpleTV.OSD.ShowMessageT({imageParam = imageParam, text = t[j], color = color, showTime = 1000 * 6, id = id, once = once})
			end
	end
	local function lunaJson_decode(json_, pos_, nullv_, arraylen_)
--[[The MIT License (MIT)
Copyright (c) 2015-2017 Shunsuke Shimizu (grafi)
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
https://github.com/grafi-tt/lunaJson
]]
		local setmetatable, tonumber, tostring = setmetatable, tonumber, tostring
		local floor, inf = math.floor, math.huge
		local mininteger, tointeger = math.mininteger or nil, math.tointeger or nil
		local byte, char, find, gsub, match, sub = string.byte, string.char, string.find, string.gsub, string.match, string.sub
		local function _decode_error(pos, errmsg)
			error("json parse error at " .. pos .. " pos.: " .. errmsg, 2)
		end
		local f_str_ctrl_pat
		if _VERSION == "Lua 5.1" then
			f_str_ctrl_pat = '[^\32-\255]'
		else
			f_str_ctrl_pat = '[\0-\31]'
		end
		local _ENV = nil
		local json, pos, nullv, arraylen, rec_depth
		local dispatcher, f
		local function decode_error(errmsg)
		 return _decode_error(pos, errmsg)
		end
		local function f_err()
			decode_error('invalid value')
		end
		local function f_nul()
			if sub(json, pos, pos+2) == 'ull' then
				pos = pos+3
			return nullv
			end
			decode_error('invalid value')
		end
		local function f_fls()
			if sub(json, pos, pos+3) == 'alse' then
				pos = pos+4
				return false
			end
			decode_error('invalid value')
		end
		local function f_tru()
			if sub(json, pos, pos+2) == 'rue' then
				pos = pos+3
				return true
			end
			decode_error('invalid value')
		end
		local radixmark = match(tostring(0.5), '[^0-9]')
		local fixedtonumber = tonumber
		if radixmark ~= '.' then
			if find(radixmark, '%W') then
				radixmark = '%' .. radixmark
			end
			fixedtonumber = function(s)
				return tonumber(gsub(s, '.', radixmark))
			end
		end
		local function number_error()
			return decode_error('invalid number')
		end
		local function f_zro(mns)
			local num, c = match(json, '^(%.?[0-9]*)([-+.A-Za-z]?)', pos)
			if num == '' then
				if c == '' then
					if mns then
						return -0.0
					end
					return 0
				end
				if c == 'e' or c == 'E' then
					num, c = match(json, '^([^eE]*[eE][-+]?[0-9]+)([-+.A-Za-z]?)', pos)
					if c == '' then
						pos = pos + #num
						if mns then
							return -0.0
						end
						return 0.0
					end
				end
				number_error()
			end
			if byte(num) ~= 0x2E or byte(num, -1) == 0x2E then
				number_error()
			end
			if c ~= '' then
				if c == 'e' or c == 'E' then
					num, c = match(json, '^([^eE]*[eE][-+]?[0-9]+)([-+.A-Za-z]?)', pos)
				end
				if c ~= '' then
					number_error()
				end
			end
			pos = pos + #num
			c = fixedtonumber(num)
			if mns then
				c = -c
			end
			return c
		end
		local function f_num(mns)
			pos = pos-1
			local num, c = match(json, '^([0-9]+%.?[0-9]*)([-+.A-Za-z]?)', pos)
			if byte(num, -1) == 0x2E then
				number_error()
			end
			if c ~= '' then
				if c ~= 'e' and c ~= 'E' then
					number_error()
				end
				num, c = match(json, '^([^eE]*[eE][-+]?[0-9]+)([-+.A-Za-z]?)', pos)
				if not num or c ~= '' then
					number_error()
				end
			end
			pos = pos + #num
			c = fixedtonumber(num)
			if mns then
				c = -c
				if c == mininteger and not find(num, '[^0-9]') then
					c = mininteger
				end
			end
			return c
		end
		local function f_mns()
			local c = byte(json, pos)
			if c then
				pos = pos+1
				if c > 0x30 then
					if c < 0x3A then
						return f_num(true)
					end
				else
					if c > 0x2F then
						return f_zro(true)
					end
				end
			end
			decode_error('invalid number')
		end
		local f_str_hextbl = {
			0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7,
			0x8, 0x9, inf, inf, inf, inf, inf, inf,
			inf, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF, inf,
			inf, inf, inf, inf, inf, inf, inf, inf,
			inf, inf, inf, inf, inf, inf, inf, inf,
			inf, inf, inf, inf, inf, inf, inf, inf,
			inf, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF,
			__index = function()
				return inf
			end
		}
		setmetatable(f_str_hextbl, f_str_hextbl)
		local f_str_escapetbl = {
			['"'] = '"',
			['\\'] = '\\',
			['/'] = '/',
			['b'] = '\b',
			['f'] = '\f',
			['n'] = '\n',
			['r'] = '\r',
			['t'] = '\t',
			__index = function()
				decode_error("invalid escape sequence")
			end
		}
		setmetatable(f_str_escapetbl, f_str_escapetbl)
		local function surrogate_first_error()
			return decode_error("1st surrogate pair byte not continued by 2nd")
		end
		local f_str_surrogate_prev = 0
		local function f_str_subst(ch, ucode)
			if ch == 'u' then
				local c1, c2, c3, c4, rest = byte(ucode, 1, 5)
				ucode = f_str_hextbl[c1-47] * 0x1000 +
						f_str_hextbl[c2-47] * 0x100 +
						f_str_hextbl[c3-47] * 0x10 +
						f_str_hextbl[c4-47]
				if ucode ~= inf then
					if ucode < 0x80 then
						if rest then
							return char(ucode, rest)
						end
						return char(ucode)
					elseif ucode < 0x800 then
						c1 = floor(ucode / 0x40)
						c2 = ucode - c1 * 0x40
						c1 = c1 + 0xC0
						c2 = c2 + 0x80
						if rest then
							return char(c1, c2, rest)
						end
						return char(c1, c2)
					elseif ucode < 0xD800 or 0xE000 <= ucode then
						c1 = floor(ucode / 0x1000)
						ucode = ucode - c1 * 0x1000
						c2 = floor(ucode / 0x40)
						c3 = ucode - c2 * 0x40
						c1 = c1 + 0xE0
						c2 = c2 + 0x80
						c3 = c3 + 0x80
						if rest then
							return char(c1, c2, c3, rest)
						end
						return char(c1, c2, c3)
					elseif 0xD800 <= ucode and ucode < 0xDC00 then
						if f_str_surrogate_prev == 0 then
							f_str_surrogate_prev = ucode
							if not rest then
								return ''
							end
							surrogate_first_error()
						end
						f_str_surrogate_prev = 0
						surrogate_first_error()
					else
						if f_str_surrogate_prev ~= 0 then
							ucode = 0x10000 +
									(f_str_surrogate_prev - 0xD800) * 0x400 +
									(ucode - 0xDC00)
							f_str_surrogate_prev = 0
							c1 = floor(ucode / 0x40000)
							ucode = ucode - c1 * 0x40000
							c2 = floor(ucode / 0x1000)
							ucode = ucode - c2 * 0x1000
							c3 = floor(ucode / 0x40)
							c4 = ucode - c3 * 0x40
							c1 = c1 + 0xF0
							c2 = c2 + 0x80
							c3 = c3 + 0x80
							c4 = c4 + 0x80
							if rest then
								return char(c1, c2, c3, c4, rest)
							end
							return char(c1, c2, c3, c4)
						end
						decode_error("2nd surrogate pair byte appeared without 1st")
					end
				end
				decode_error("invalid unicode codepoint literal")
			end
			if f_str_surrogate_prev ~= 0 then
				f_str_surrogate_prev = 0
				surrogate_first_error()
			end
			return f_str_escapetbl[ch] .. ucode
		end
		local f_str_keycache = setmetatable({}, {__mode="v"})
		local function f_str(iskey)
			local newpos = pos
			local tmppos, c1, c2
			repeat
				newpos = find(json, '"', newpos, true)
				if not newpos then
					decode_error("unterminated string")
				end
				tmppos = newpos-1
				newpos = newpos+1
				c1, c2 = byte(json, tmppos-1, tmppos)
				if c2 == 0x5C and c1 == 0x5C then
					repeat
						tmppos = tmppos-2
						c1, c2 = byte(json, tmppos-1, tmppos)
					until c2 ~= 0x5C or c1 ~= 0x5C
					tmppos = newpos-2
				end
			until c2 ~= 0x5C
			local str = sub(json, pos, tmppos)
			pos = newpos
			if iskey then
				tmppos = f_str_keycache[str]
				if tmppos then
					return tmppos
				end
				tmppos = str
			end
			if find(str, f_str_ctrl_pat) then
				decode_error("unescaped control string")
			end
			if find(str, '\\', 1, true) then
				str = gsub(str, '\\(.)([^\\]?[^\\]?[^\\]?[^\\]?[^\\]?)', f_str_subst)
				if f_str_surrogate_prev ~= 0 then
					f_str_surrogate_prev = 0
					decode_error("1st surrogate pair byte not continued by 2nd")
				end
			end
			if iskey then
				f_str_keycache[tmppos] = str
			end
			return str
		end
		local function f_ary()
			rec_depth = rec_depth + 1
			if rec_depth > 1000 then
				decode_error('too deeply nested json (> 1000)')
			end
			local ary = {}
			pos = match(json, '^[ \n\r\t]*()', pos)
			local i = 0
			if byte(json, pos) == 0x5D then
				pos = pos+1
			else
				local newpos = pos
				repeat
					i = i+1
					f = dispatcher[byte(json,newpos)]
					pos = newpos+1
					ary[i] = f()
					newpos = match(json, '^[ \n\r\t]*,[ \n\r\t]*()', pos)
				until not newpos
				newpos = match(json, '^[ \n\r\t]*%]()', pos)
				if not newpos then
					decode_error("no closing bracket of an array")
				end
				pos = newpos
			end
			if arraylen then
				ary[0] = i
			end
			rec_depth = rec_depth - 1
			return ary
		end
		local function f_obj()
			rec_depth = rec_depth + 1
			if rec_depth > 1000 then
				decode_error('too deeply nested json (> 1000)')
			end
			local obj = {}
			pos = match(json, '^[ \n\r\t]*()', pos)
			if byte(json, pos) == 0x7D then
				pos = pos+1
			else
				local newpos = pos
				repeat
					if byte(json, newpos) ~= 0x22 then
						decode_error("not key")
					end
					pos = newpos+1
					local key = f_str(true)
					f = f_err
					local c1, c2, c3 = byte(json, pos, pos+3)
					if c1 == 0x3A then
						if c2 ~= 0x20 then
							f = dispatcher[c2]
							newpos = pos+2
						else
							f = dispatcher[c3]
							newpos = pos+3
						end
					end
					if f == f_err then
						newpos = match(json, '^[ \n\r\t]*:[ \n\r\t]*()', pos)
						if not newpos then
							decode_error("no colon after a key")
						end
						f = dispatcher[byte(json, newpos)]
						newpos = newpos+1
					end
					pos = newpos
					obj[key] = f()
					newpos = match(json, '^[ \n\r\t]*,[ \n\r\t]*()', pos)
				until not newpos
				newpos = match(json, '^[ \n\r\t]*}()', pos)
				if not newpos then
					decode_error("no closing bracket of an object")
				end
				pos = newpos
			end
			rec_depth = rec_depth - 1
			return obj
		end
		dispatcher = { [0] =
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_str, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_mns, f_err, f_err,
			f_zro, f_num, f_num, f_num, f_num, f_num, f_num, f_num,
			f_num, f_num, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_ary, f_err, f_err, f_err, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_fls, f_err,
			f_err, f_err, f_err, f_err, f_err, f_err, f_nul, f_err,
			f_err, f_err, f_err, f_err, f_tru, f_err, f_err, f_err,
			f_err, f_err, f_err, f_obj, f_err, f_err, f_err, f_err,
			__index = function()
				decode_error("unexpected termination")
			end
		}
		setmetatable(dispatcher, dispatcher)
		json, pos, nullv, arraylen = json_, pos_, nullv_, arraylen_
		rec_depth = 0
		pos = match(json, '^[ \n\r\t]*()', pos)
		f = dispatcher[byte(json, pos)]
		pos = pos+1
		local v = f()
		if pos_ then
		 return v, pos
		else
			f, pos = find(json, '^[ \n\r\t]*', pos)
			if pos ~= #json then
				-- decode_error('json ended')
			end
		 return v
		end
	 return decode
	end
	local function GetApiKey()
			local function webApiKey()
				local session = m_simpleTV.Http.New(userAgent)
					if not session then return end
				m_simpleTV.Http.SetTimeout(session, 14000)
				local url = decode64('aHR0cHM6Ly93d3cueW91dHViZS5jb20vcy9fL2thYnVraS9fL2pzL2s9a2FidWtpLmJhc2VfemRzLmVuX1VTLi1KcDN1bDRMbzBZLk8vYW09SW9BQVFnQUUvcnQ9ai9kPTEvZGc9MC9jdD16Z21zL3JzPUFOalJoVmtmazRsbnFhWXlZX05MTzV4QmhpTGdXYkYzMGcvbT1iYXNl')
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				m_simpleTV.Http.Close(session)
					if rc ~= 200 then return end
		 	 return answer:match('ya%("INNERTUBE_API_KEY","([^"]+)')
			end
		local key = webApiKey()
		if not key then
			ShowMsg(m_simpleTV.User.YT.Lng.error .. '\nAPI Key not found')
			m_simpleTV.Common.Sleep(2000)
		end
		m_simpleTV.User.YT.apiKey = key or ''
		m_simpleTV.User.YT.apiKeyHeader = decode64('UmVmZXJlcjogaHR0cHM6Ly93d3cueW91dHViZS5jb20vdHY')
	end
	local function table_reversa(t)
		local tbl = {}
		local p = #tbl
			for i = #t, 1, -1 do
				p = p + 1
				tbl[p] = t[i]
			end
	 return tbl
	end
	local function urls_encode(str)
		str = string.gsub(str, '([^%w:/=.&%-?_])',
				function(c)
				 return string.format('%%%02X', string.byte(c))
				end)
	 return string.gsub(str, ' ', '+')
	end
	local function stringToHex(str)
	 return (str:gsub('.',
		function (c)
		 return string.format('\\x%02X', string.byte(c))
		end))
	end
	local function stringFromHex(str)
	 return (str:gsub('\\x(..)',
		function (c)
		 return string.char(tonumber(c, 16))
		end))
	end
	local function split_str(source, delimiters)
		local elements = {}
		local pattern
		if not delimiters or delimiters == '' then
			pattern = '.'
		else
			pattern = '([^' .. delimiters .. ']+)'
		end
		source:gsub(pattern, function(value) elements[#elements + 1] = value end)
	 return elements
	end
	local function timeStamp(isodt)
		local pattern = '(%d+)%-(%d+)%-(%d+)T(%d+):(%d+)'
		local xyear, xmonth, xday, xhour, xminute = isodt:match(pattern)
			if not (xyear or xmonth or xday or xhour or xminute) then
				 return ''
				end
		local currenttime = os.time()
		local datetime = os.date('!*t', currenttime)
		datetime.isdst = true
		local offset = currenttime - os.time(datetime)
		local convertedTimestamp = os.time({year = xyear, month = xmonth, day = xday, hour = xhour, min = xminute})
	 return (convertedTimestamp + offset)
	end
	local function secondsToClock(sec)
			if not sec or sec < 3 then
			 return ''
			end
		sec = string.format('%01d:%02d:%02d',
									math.floor(sec / 3600),
									math.floor(sec / 60) % 60,
									math.floor(sec % 60))
	 return sec:gsub('^0[0:]+(.+:)', '%1')
	end
	local function unescape_html(str)
	 return htmlEntities.decode(str)
	end
	local function title_clean(s)
		s = s:gsub('%c', ' ')
		s = s:gsub('%%22', '"')
		s = s:gsub('\\u0026', '&')
		s = s:gsub('\\u2060', '')
		s = s:gsub('\\u200%a', '')
		s = unescape_html(s)
		s = s:gsub('%s+', ' ')
		s = s:gsub('\\', '\\')
	 return s
	end
	local function desc_clean(d)
		d = d:gsub('%%22', '"')
		d = d:gsub('\\u200%a', '')
		d = d:gsub('\\u202%a', '')
		d = d:gsub('\\u00ad', '')
		d = d:gsub('\\r', '')
		d = d:gsub('\r', '')
		d = d:gsub('\\n', '\n')
		d = d:gsub('\n\n[\n]+', '\n\n')
		d = unescape3(d)
		d = unescape_html(d)
		d = d:gsub('\\', '\\')
	 return d
	end
	local function desc_format_text(desc, isSearch)
		desc = desc_clean(desc)
		desc = string.gsub(desc, '(https?://%S+)',
				function(c)
					c = c:gsub('#', '%%23')
					if c:match('%.%.%p*$') then
						c = string.format('<span style="color:%%23817c76; font-size:small;">%s</span>', c)
					else
						c = string.format('<a href="%s" style="color:%%23319785; font-size:small; text-decoration:none">%s</a>', c, c)
					end
				 return c:gsub('([.,)]+)"', '"%1'):gsub('([.,)]+)</a>', '</a>%1')
				end)
		desc = string.gsub(desc, '(%d+[:%d+]+)',
				function(c)
						if not (c:match('%d+:%d+$')
							or c:match('%d+:%d+:%d+$'))
							or c:match('::')
						then
						 return
						end
				 return string.format('<span style="color:%%23e6e76d; font-size:small;">%s</span>', c)
				end)
		if not isSearch then
			desc = string.gsub(desc, 'none">(https?://[%a.]*youtu[.combe][^<]+)<',
				function(c)
						if c:match('sub_confirmation')
							or c:match('subscription_center')
							or c:match('/join$')
						then
						 return
						end
				 return string.format('none">%s</a> <a href="simpleTVLua:PlayAddressT_YT(\'%s\')"><img src="' .. m_simpleTV.User.YT.playPicFromDisk ..'" height="32" valign="top"><', c, stringToHex(c))
				end)
			desc = string.gsub(desc, '#([^\'%s%c/#,:%-?)]+)',
				function(c)
					if c:match('%.%.$') then
						c = string.format('<span style="color:%%23817c76; font-size:small;">#%s</span>', c)
					elseif (c:match('^%d+%p*$') and #c < 6) or c:match('%.[^.]+$') then
					 return
					else
						c = string.format('<a href="simpleTVLua:PlayAddressT_YT(\'https://www.youtube.com/hashtag/%s\')" style="color:#436FAF; font-size:small; text-decoration:none">#%s</a>', stringToHex(c:gsub('%p+$', '')), c)
					end
				 return c:gsub('(%p+)</a>', '</a>%1')
				end)
		else
			desc = string.gsub(desc, '#([^\'%s%c/#,:%-?)]+)',
				function(c)
					if c:match('%.%.$') then
						c = string.format('<span style="color:%%23817c76; font-size:small;">#%s</span>', c)
					elseif (c:match('^%d+%p*$') and #c < 6) or c:match('%.[^.]+$') then
					 return
					else
						c = string.format('<a href="https://www.youtube.com/hashtag/%s" style="color:%%23154C9C; font-size:small; text-decoration:none">#%s</a>', c:gsub('%p+$', ''), c)
					end
				 return c:gsub('(%p+)</a>', '</a>%1')
				end)
		end
		desc = desc:gsub('%%23', '#')
		desc = desc:gsub('"+', '"')
		desc = desc:gsub('\n', '<br>')
		desc = string.format('<p>%s</p>', desc)
	 return desc
	end
	local function desc_html(desc, logo, name, adr, isSearch)
		desc = desc or ''
		if desc ~= '' then
			local err, d = pcall(desc_format_text, desc, isSearch)
			if err == false then
				desc = string.format('<p style="color:#ff0000; font-size:small">%s: %s</p>', m_simpleTV.User.YT.Lng.desc, m_simpleTV.User.YT.Lng.error)
			else
				desc = d
			end
		end
		adr = adr:gsub('&is%a+=%a+', '')
		local link = string.format('<a href="%s" style="color:#154C9C; font-size:small; text-decoration:none">🌎 %s</a>', adr, m_simpleTV.User.YT.Lng.link)
		if m_simpleTV.User.YT.isVideo == true and m_simpleTV.User.YT.isChapters then
			link = string.format('%s<br><a href="simpleTVLua:m_simpleTV.Control.ExecuteAction(37) m_simpleTV.Control.ExecuteAction(116)" style="color:#436FAF; font-size: small; text-decoration:none">🕜 %s</a>', link, m_simpleTV.User.YT.Lng.chapter)
		end
		desc = string.format('<html><body bgcolor="#181818"><table width="99%%"><tr><td style="padding: 10px 10px 10px;"><a href="%s"><img src="%s"</a></td><td style="padding: 10px 10px 10px; color:#ebebeb; vertical-align:middle;"><h4><font color="#ebeb00">%s</h4><hr>%s%s</td></tr></table></body></html>', adr, logo, name, link, desc)
	 return desc
	end
	local function ShowInfo(info, bcolor, txtparm, color)
			local function datScr()
				local f = m_simpleTV.MainScriptDir .. 'user/video/YT.lua'
				local fhandle = io.open(f, 'r')
					if not fhandle then
					 return ''
					end
				local dat = fhandle:read(100)
				fhandle:close()
				dat = ' [' .. (dat:match('%d+[/.%-]%d+[/.%-]%d+') or '') .. ']'
			 return decode64('WW91VHViZSBieSBOZXh0ZXJyIGVkaXRpb24') .. dat
			end
		m_simpleTV.Control.ExecuteAction(37)
		if not info then
				local function truncateUtf8(str, n)
						if m_simpleTV.Common.midUTF8 then
						 return m_simpleTV.Common.midUTF8(str, 0, n)
						end
					str = m_simpleTV.Common.UTF8ToUTF16(str)
					str = str:sub(1, n)
					str = m_simpleTV.Common.UTF16ToUTF8(str)
				 return str
				end
			color = ARGB(255, 128, 128, 255)
			bcolor = ARGB(144, 0, 0, 0)
			txtparm = 1 + 4
			local codec = ''
			local title
			if #m_simpleTV.User.YT.title > 70 then
				title = truncateUtf8(m_simpleTV.User.YT.title, 55) .. '...'
			else
				title = m_simpleTV.User.YT.title
			end
			local ti = m_simpleTV.Control.GetCodecInfo()
			if ti then
				local codecD, typeD, resD
				local t, i = {}, 1
					for w in dumpValue(ti):gmatch('{.-}') do
						t[i] = {}
						codecD = w:match('%["Codec"%] = ([^,}]+)')
						typeD = w:match('%["Type"%] = ([^,}]+)')
						if codecD and typeD then
							typeD = typeD:gsub('Video', m_simpleTV.User.YT.Lng.video .. ': ')
							typeD = typeD:gsub('Audio', m_simpleTV.User.YT.Lng.audio .. ': ')
							typeD = typeD:gsub('Subtitle', m_simpleTV.User.YT.Lng.sub .. ': ')
							codecD = typeD .. codecD
							codecD = '\n' .. codecD
						end
						resD = w:match('%["Video resolution"%] = ([^,}]+)')
						if resD then
							resD = m_simpleTV.User.YT.Lng.qlty .. ': ' .. resD
							resD = '\n' .. resD
						end
						t[i] = (codecD or '') .. (resD or '')
						i = i + 1
					end
				codec = table.concat(t)
			end
			local dur, publishedAt, author
			if m_simpleTV.User.YT.isLive == true then
				dur = ''
				author = m_simpleTV.User.YT.Lng.live .. ' | '
						.. m_simpleTV.User.YT.Lng.channel .. ': '
						.. m_simpleTV.User.YT.author
				local timeSt = timeStamp(m_simpleTV.User.YT.actualStartTime)
				timeSt = os.date('%y %d %m %H %M', tonumber(timeSt))
				local year, day, month, hour, min = timeSt:match('(%d+) (%d+) (%d+) (%d+) (%d+)')
				publishedAt = m_simpleTV.User.YT.Lng.started .. ': '
						.. string.format('%d:%02d (%d/%d/%02d)', hour, min, day, month, year)
			else
				dur = m_simpleTV.User.YT.Lng.duration .. ': ' .. secondsToClock(m_simpleTV.User.YT.duration)
				author = m_simpleTV.User.YT.Lng.upLoadOnCh .. ': ' .. m_simpleTV.User.YT.author
				local year, month, day = m_simpleTV.User.YT.publishedAt:match('(%d+)%-(%d+)%-(%d+)')
				year = year:sub(2, 4)
				publishedAt = m_simpleTV.User.YT.Lng.published .. ': '
						.. string.format('%d/%d/%02d', day, month, year)
			end
			info = title .. '\n'
					.. author .. '\n'
					.. publishedAt .. '\n'
					.. dur .. '\n'
					.. codec
			info = info:gsub('[%\n]+', '\n')
			info = info:gsub('%\n$', '')
		end
		local addElement = m_simpleTV.OSD.AddElement
		local removeElement = m_simpleTV.OSD.RemoveElement
		local q = {}
		q.once = 1
		q.zorder = 0
		q.cx = 0
		q.cy = 0
		q.id = 'YT_TEXT_INFO'
		q.class = 'TEXT'
		q.align = 0x0202
		q.top = 0
		q.color = color or ARGB(255, 255, 255, 255)
		q.font_italic = 0
		q.font_addheight = 6
		q.padding = 20
		q.textparam = txtparm or (1 + 4)
		q.text = info
		q.background = 0
		q.backcolor0 = bcolor or ARGB(144, 153, 0, 0)
		q.isInteractive = true
		q.color_UnderMouse = m_simpleTV.Interface.ColorBrightness(q.color, 50)
		addElement(q)
		q = {}
		q.id = 'YT_DIV_CR'
		q.cx = 200
		q.cy = 200
		q.class = 'DIV'
		q.minresx = 800
		q.minresy = 600
		q.align = 0x0103
		q.left = 0
		q.once = 1
		q.zorder = 1
		q.background = -1
		addElement(q)
		q = {}
		q.id = 'YT_DIV_CR_TEXT'
		q.cx = 0
		q.cy = 0
		q.class = 'TEXT'
		q.minresx = 0
		q.minresy = 0
		q.align = 0x0103
		q.text = datScr()
		q.color = ARGB(64, 250, 250, 250)
		q.font_height = -15
		q.font_weight = 700
		q.font_underline = 0
		q.font_italic = 0
		q.font_name = 'Arial'
		q.textparam = 0
		q.left = 5
		q.top = 5
		q.glow = 1
		q.glowcolor = ARGB(144, 0, 0, 0)
		addElement(q,'YT_DIV_CR')
			local function elementsRemove()
				removeElement('YT_TEXT_INFO')
				removeElement('YT_DIV_CR')
				if m_simpleTV.Control.GetState() == 0 then
					m_simpleTV.Control.ExecuteAction(108)
				end
			end
			if m_simpleTV.Common.WaitUserInput(5000) == 1 then
				elementsRemove()
			 return
			end
			if m_simpleTV.Common.WaitUserInput(3000) == 1 then
				elementsRemove()
			 return
			end
		elementsRemove()
	end
	local function StopOnErr(n, txt)
			if urlAdr:match('PARAMS=psevdotv') then return end
		if session then
			m_simpleTV.Http.Close(session)
		end
		m_simpleTV.Control.CurrentAddress = m_simpleTV.User.YT.logoPicFromDisk .. '$OPT:video-filter=adjust$OPT:saturation=0$OPT:video-filter=gaussianblur$OPT:image-duration=5'
		local mes
		if m_simpleTV.User.YT.isAuth
			and (inAdr:match('list=WL')
			or inAdr:match('list=LL')
			or inAdr:match('list=LM')
			or (inAdr:match('/feed/')
			and not inAdr:match('/feed/storefront')
			and not inAdr:match('/feed/trending')))
		then
			mes = '\n' .. m_simpleTV.User.YT.Lng.noCookies
			m_simpleTV.Control.ExecuteAction(11)
		else
			mes = ' [' .. n .. ']\n' .. (txt or '')
		end
		mes = m_simpleTV.User.YT.Lng.error .. mes
		ShowMsg(mes)
		m_simpleTV.Control.SetTitle(m_simpleTV.User.YT.Lng.error .. ' [' .. n .. ']')
	end
	local function debug_InfoInFile(infoInFile, retAdr, index, t, noItag22, inf01, inf0, title)
			if not infoInFile then return end
		local scr_time = string.format('%.3f', (os.clock() - infoInFile))
		local calc = scr_time - inf0
		local adr = m_simpleTV.Common.fromPercentEncoding(retAdr)
		local string_rep = string.rep('–', 70) .. '\n'
		index = noItag22 or index
		local qlty = t[index].qlty
		if qlty and qlty < 100 then
			qlty = nil
		end
		infoInFile = string_rep
						.. 'url: https://www.youtube.com/watch?v=' .. m_simpleTV.User.YT.vId .. '\n'
						.. string_rep
						.. 'qlty: ' .. tostring(qlty)
						.. ' | video itag: ' .. tostring(t[index].itag)
						.. ' | audio itag: ' .. tostring(t[index].aItag) .. '\n'
						.. string_rep
						.. 'cipher: ' .. tostring(t[index].isCipher)
						.. ' | sts: ' .. tostring(m_simpleTV.User.YT.sts) .. '\n'
						.. string_rep
						.. 'time: ' .. scr_time .. ' s.'
						.. ' | request: ' .. inf0 .. ' s.'
						.. ' | calc: ' .. calc .. ' s.\n'
						.. string_rep
						.. 'title: ' .. title:gsub('%c', ' ') .. '\n'
						.. string_rep
						.. 'description:\n\n'
						.. m_simpleTV.User.YT.desc .. '\n'
						.. string_rep
						.. 'qlty table:\n\n'
						.. (inf01 or '') .. '\n'
						.. string_rep
						.. 'cookies:\n\n'
						.. m_simpleTV.User.YT.cookies:gsub('^[;]*(.-)[;]$', '%1'):gsub(';+', '\n') .. '\n'
						.. string_rep
						.. 'address:\n\n'
						.. adr:gsub('%$', '\n\n$'):gsub('slave=', 'slave=\n\n'):gsub('%#', '\n\n#\n\n') .. '\n'
		debug_in_file(infoInFile, m_simpleTV.Common.GetMainPath(2) .. 'YT_play_info.txt', true)
	end
	local function Search(sAdr)
		local types, yt, header, url
		local eventType = ''
		if sAdr:match('^%s*%-%s*%-%s*%-') then
			types = 'channel'
			header = m_simpleTV.User.YT.Lng.channel
			yt = 'channel/'
		elseif sAdr:match('^%s*%-%s*%-') then
			types = 'playlist'
			header = m_simpleTV.User.YT.Lng.plst
			yt = 'playlist?list='
		elseif sAdr:match('^%s*%-%s*%+') then
			eventType = '&eventType=live'
			types = 'video'
			header = m_simpleTV.User.YT.Lng.live
			yt = 'watch?v='
		elseif sAdr:match('^%-related=') then
			types = 'related'
			header = m_simpleTV.User.YT.Lng.relatedVideos
			yt = 'watch?v='
		else
			types = 'video&videoDimension=2d'
			header = m_simpleTV.User.YT.Lng.video
			yt = 'watch?v='
		end
		if not m_simpleTV.User.YT.apiKey then
			GetApiKey()
		end
		if types == 'related' then
			sAdr = sAdr:gsub('%-related=', '')
			url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&fields=nextPageToken,items/snippet/title,items/id/videoId,items/snippet/thumbnails/default/url,items/snippet/description,items/snippet/liveBroadcastContent,items/snippet/channelTitle&type=video&relatedToVideoId=' .. sAdr .. '&key=' .. m_simpleTV.User.YT.apiKey .. '&relevanceLanguage=' .. m_simpleTV.User.YT.Lng.hl
		else
			sAdr = sAdr:gsub('^[%-%+%s]+(.-)%s*$', '%1')
				if sAdr == '' then return end
			sAdr = m_simpleTV.Common.toPercentEncoding(sAdr)
			url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&q=' .. sAdr .. '&type=' .. types .. '&fields=nextPageToken,items/id,items/snippet/title,items/snippet/thumbnails/default/url,items/snippet/description,items/snippet/liveBroadcastContent,items/snippet/channelTitle&maxResults=50' .. eventType .. '&key=' .. m_simpleTV.User.YT.apiKey .. '&relevanceLanguage=' .. m_simpleTV.User.YT.Lng.hl
		end
		local t = {}
		local k, i = 1, 1
		local adrUrl = url
			while true do
					if k > 200 then break end
				local rc, answer = m_simpleTV.Http.Request(session, {url = adrUrl, headers = m_simpleTV.User.YT.apiKeyHeader})
					if rc ~= 200 then break end
					if not answer:match('"id"') then break end
				local err, tab = pcall(lunaJson_decode, answer)
					if err == false
						or not tab.items
					then
					 break
					end
				local j = 1
					while true do
							if not tab.items[j] or k > 200 then break end
						if eventType == '&eventType=live'
							or (eventType == ''
								and tab.items[j].snippet
								and tab.items[j].snippet.liveBroadcastContent
								and tab.items[j].snippet.liveBroadcastContent ~= 'live')
						then
							local name = title_clean(tab.items[j].snippet.title)
							t[k] = {}
							t[k].Id = k
							t[k].Name = name
							t[k].Address = 'https://www.youtube.com/' .. yt .. (tab.items[j].id.videoId or tab.items[j].id.playlistId or tab.items[j].id.channelId)
							if isInfoPanel == true then
								if tab.items[j].snippet
									and tab.items[j].snippet.thumbnails
									and tab.items[j].snippet.thumbnails.default
									and tab.items[j].snippet.thumbnails.default.url
								then
									t[k].InfoPanelLogo = tab.items[j].snippet.thumbnails.default.url
								else
									t[k].InfoPanelLogo = m_simpleTV.User.YT.logoPicFromDisk
								end
								t[k].InfoPanelName = name
								t[k].InfoPanelShowTime = 10000
								local desc = tab.items[j].snippet.description
								local panelDescName
								if desc and desc ~= '' then
									panelDescName = m_simpleTV.User.YT.Lng.desc .. ' | '
								end
								t[k].InfoPanelDesc = desc_html(desc, t[k].InfoPanelLogo, name, t[k].Address, true)
								if tab.items[j].snippet.channelTitle then
									t[k].InfoPanelTitle = (panelDescName or '')
														.. m_simpleTV.User.YT.Lng.channel
														.. ': ' .. title_clean(tab.items[j].snippet.channelTitle)
								end
							end
							k = k + 1
						end
						j = j + 1
					end
				local nextPageToken = answer:match('"nextPageToken": "([^"]+)')
					if not nextPageToken then break end
				adrUrl = url .. '&pageToken=' .. nextPageToken
			end
	 return t, types, header
	end
	local function header_Auth()
		if m_simpleTV.User.YT.isAuth then
			local ostime = os.time()
			local origin = 'https://www.youtube.com'
			local toHash = string.format('%s %s %s', ostime, m_simpleTV.User.YT.isAuth, origin)
			local hash = m_simpleTV.Common.CryptographicHash(toHash, 'Sha1', true)
		 return string.format('\nAuthorization: SAPISIDHASH %s_%s', ostime, hash)
		end
	 return ''
	end
	local function GetUrlWatchVideos(url)
		local session = m_simpleTV.Http.New(userAgent, nil, true)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 14000)
		m_simpleTV.Http.SetRedirectAllow(session, false)
		m_simpleTV.Http.SetCookies(session, url, m_simpleTV.User.YT.cookies, '')
		m_simpleTV.Http.Request(session, {url = url})
		local raw = m_simpleTV.Http.GetRawHeader(session)
		m_simpleTV.Http.Close(session)
			if not raw then return end
	 return raw:match('Location: (.-)\n')
	end
	local function Chapters()
			local function chapTab(t)
				local tab = {}
				local seekp = -1
				local duration = m_simpleTV.User.YT.duration
					for i = 1, #t do
						if t[i]:match('%d+:%d+')
							and not t[i]:match('://')
						then
							t[i] = t[i]:gsub('^(.-)([%d:]*%d+:%d+)(.-)$', ' %1 %2 %3 ')
							local sec = t[i]:match(':(%d+)%s')
							local min = t[i]:match('(%d+):%d+%s')
							local hour = t[i]:match('(%d+):%d+:%d+') or 0
							local seekpoint = (sec + (min * 60) + (hour * 3600))
							local title = t[i]:gsub('[%d:]*%d+:%d+', '')
							if title ~= ''
								and not title:match('^[%p%s]+$')
								and seekpoint < duration
								and seekp < seekpoint
							then
								table.insert(tab, {seekpoint = seekpoint, title = title})
								seekp = seekpoint
							end
							if #tab == 2 and tab[1].seekpoint >= tab[2].seekpoint then
								table.remove(tab, 1)
							end
						end
					end
			 return tab
			end
		local d = desc_clean(m_simpleTV.User.YT.desc)
		d = split_str(d, '\n')
		local t = chapTab(d)
			if #t < 3 then return end
		if t[1].seekpoint ~= 0 then
			table.insert(t, 1, {seekpoint = 0, title = ''})
		end
		local chaptersT = {}
		chaptersT.chapters = {}
			for i = 1, #t do
				local title = t[i].title
				title = title:gsub('%s+', ' ')
				title = title:gsub('–', '-')
				title = title:gsub('^%s*"(.-)"%s*$', '%1')
				title = title:gsub('[(%[][%s%-]*[%])]', '')
				title = title:gsub('^[|:%s%-.]*(.-)[|:%s%-.]*$', '%1')
				chaptersT.chapters[i] = {}
				chaptersT.chapters[i].seekpoint = t[i].seekpoint * 1000
				chaptersT.chapters[i].name = title
			end
		m_simpleTV.Control.SetChaptersDesc(chaptersT)
		m_simpleTV.User.YT.isChapters = true
	end
	local function Thumbs(storyboards)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		local t = split_str(storyboards, '|')
			if not t or #t < 2 then return end
		local urlPattern = t[1]
			if urlPattern == '' then return end
		local q = split_str(t[#t], '#')
			if not q or #q < 8 then return end
		local samplingFrequency = tonumber(q[6]) or 0
		local thumbsPerImage = (tonumber(q[4]) or 0) * (tonumber(q[5]) or 0)
		local thumbWidth = tonumber(q[1]) or 0
		local thumbHeight = tonumber(q[2]) or 0
		local NPattern = q[7]
			if samplingFrequency == 0
				or thumbsPerImage == 0
				or thumbWidth == 0
				or thumbHeight == 0
				or NPattern == nil
			then
			 return
			end
		urlPattern = urlPattern:gsub('$L', #t - 2)
		urlPattern = urlPattern .. '&sigh=' .. m_simpleTV.Common.toPercentEncoding(q[8])
		m_simpleTV.User.YT.ThumbsInfo = {}
		m_simpleTV.User.YT.ThumbsInfo.samplingFrequency = samplingFrequency
		m_simpleTV.User.YT.ThumbsInfo.thumbsPerImage = thumbsPerImage
		m_simpleTV.User.YT.ThumbsInfo.thumbWidth = thumbWidth
		m_simpleTV.User.YT.ThumbsInfo.thumbHeight = thumbHeight
		m_simpleTV.User.YT.ThumbsInfo.urlPattern = urlPattern
		m_simpleTV.User.YT.ThumbsInfo.NPattern = NPattern
		if not m_simpleTV.User.YT.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_YT'
			handlerInfo.regexString = '.*youtu[\.combe]|//y2u\.be|.*invidio\.|.*hooktube\.com'
			handlerInfo.sizeFactor = m_simpleTV.User.paramScriptForSkin_thumbsSizeFactor or 0.20
			handlerInfo.backColor = m_simpleTV.User.paramScriptForSkin_thumbsBackColor or ARGB(255, 0, 0, 0)
			handlerInfo.textColor = m_simpleTV.User.paramScriptForSkin_thumbsTextColor or ARGB(240, 127, 255, 0)
			handlerInfo.glowParams = m_simpleTV.User.paramScriptForSkin_thumbsGlowParams or 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.marginBottom = m_simpleTV.User.paramScriptForSkin_thumbsMarginBottom or 0
			handlerInfo.showPreviewWhileSeek = true
			handlerInfo.clearImgCacheOnStop = false
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 44
			m_simpleTV.User.YT.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	local function title_is_no_infoPanel(title, name)
		if m_simpleTV.User.YT.isTrailer == true then
			title = title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.preview
		end
		if m_simpleTV.User.YT.isChapters == true then
			title = title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.chapter
		end
		local fps = name:match('%d+ FPS')
		if fps then
			title = title .. '\n☑ ' .. fps
		end
	 return title
	end
	local function MarkWatch_YT()
		if m_simpleTV.User.YT.videostats and not inAdr:match('&isPlst=history') then
			local sessionMarkWatch = m_simpleTV.Http.New(userAgent)
				if not sessionMarkWatch then return end
			m_simpleTV.Http.SetTimeout(sessionMarkWatch, 14000)
			local cpn_alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_'
			local t = {}
			local math_random = math.random
			local cpn_l = #cpn_alphabet
				for i = 1, 16 do
					local random_d = math_random(1, cpn_l)
					t[i] = {}
					t[i] = cpn_alphabet:sub(random_d, random_d)
				end
			local url = m_simpleTV.User.YT.videostats
				.. '&ver=2&fs=0&volume=100&muted=0&cpn='
				.. table.concat(t)
			m_simpleTV.Http.SetCookies(sessionMarkWatch, url, m_simpleTV.User.YT.cookies, '')
			m_simpleTV.Http.RequestA(sessionMarkWatch, {callback = 'MarkWatched_YT', url = url})
		end
	end
	local function StreamFormat(url, isCipher)
		if isCipher then
			url = m_simpleTV.Common.fromPercentEncoding(url)
			url = url:gsub('(.-)url=(.+)', '%2&%1')
		end
		if not url:match('ratebypass=') then
			url = url:gsub('&', '&ratebypass=yes&', 1)
		end
	 return url
	end
	local function GetSignScr()
		local sessionGetSignScr = m_simpleTV.Http.New(userAgent)
			if not sessionGetSignScr then return end
		m_simpleTV.Http.SetTimeout(sessionGetSignScr, 14000)
		local url = string.format('https://www.youtube.com/embed/%s', m_simpleTV.User.YT.vId)
		local rc, answer = m_simpleTV.Http.Request(sessionGetSignScr, {url = url})
			if rc ~= 200 then return end
		url = answer:match('[^"\']+base%.js')
			if not url then return end
		url = string.format('https://www.youtube.com%s', url)
		rc, answer = m_simpleTV.Http.Request(sessionGetSignScr, {url = url})
		m_simpleTV.Http.Close(sessionGetSignScr)
			if rc ~= 200 then return end
		local f, var = answer:match('split%(""%);((%a%w)%p%S+)')
			if not f or not var then return end
		f = f:gsub('%]', '')
		local signScr = {}
			for param in f:gmatch(var .. '%p([^)]+)') do
				local func, p = param:match('([^(]+)%(a,(%d+)')
				func = answer:match('[%p%s]' .. func .. ':function([^}]+)')
				if func:match('a%.reverse') then
					p = 0
				elseif func:match('a%.splice') then
					p = '-' .. p
				end
				signScr[#signScr + 1] = tonumber(p)
			end
		m_simpleTV.User.YT.sts = answer:match('signatureTimestamp[=:](%d+)') or answer:match('[.,]sts:["]*(%d+)')
		m_simpleTV.User.YT.signScr = signScr
	end
	local function Subtitle(tab)
		local subt = {}
		local subtList = tostring(m_simpleTV.Config.GetValue('subtitle/lang', 'simpleTVConfig') or '')
		if subtList == 'none'
			or subtList == ''
		then
			subt[1] = m_simpleTV.User.YT.Lng.hl_sub
		else
			subtList = subtList:gsub('%s', ',')
			subtList = subtList:gsub('[^%d%a,%-_]', '')
			subtList = subtList:gsub('_', '-')
			subtList = subtList:gsub(',+', ',')
			subt = split_str(subtList, ',')
			if #subt == 0 then
				subt[1] = m_simpleTV.User.YT.Lng.hl_sub
			end
		end
		local r = 1
		local languageCode, kind, q, subtAdr
			while true do
					if not subt[r] or subtAdr then break end
				q = 1
				while true do
						if not tab.captions.playerCaptionsTracklistRenderer.captionTracks[q] then break end
					languageCode = tab.captions.playerCaptionsTracklistRenderer.captionTracks[q].languageCode
					kind = tab.captions.playerCaptionsTracklistRenderer.captionTracks[q].kind
						if languageCode
							and (not kind or kind ~= 'asr')
							and languageCode == subt[r]
						then
							subtAdr = '#' .. tab.captions.playerCaptionsTracklistRenderer.captionTracks[q].baseUrl .. '&fmt=vtt'
						 break
						end
					q = q + 1
				end
				r = r + 1
			end
			if subtAdr then
			 return subtAdr, ''
			end
			if not tab.captions.playerCaptionsTracklistRenderer.translationLanguages
				or not tab.captions.playerCaptionsTracklistRenderer.translationLanguages[1]
			then
			 return
			end
		r = 1
		local lngCodeTr
			while true do
					if not subt[r] or lngCodeTr then break end
				q = 1
				while true do
						if not tab.captions.playerCaptionsTracklistRenderer.translationLanguages[q] then break end
					languageCode = tab.captions.playerCaptionsTracklistRenderer.translationLanguages[q].languageCode
						if languageCode
							and languageCode == subt[r]
						then
							lngCodeTr = languageCode
						 break
						end
					q = q + 1
				end
				r = r + 1
			end
			if not lngCodeTr then return end
		r = 1
			while true do
					if not tab.captions.playerCaptionsTracklistRenderer.captionTracks[r] then break end
				languageCode = tab.captions.playerCaptionsTracklistRenderer.captionTracks[r].languageCode
				kind = tab.captions.playerCaptionsTracklistRenderer.captionTracks[r].kind
					if languageCode
						and (not kind or kind ~= 'asr')
						and languageCode ~= 'na'
					then
						subtAdr = '#' .. tab.captions.playerCaptionsTracklistRenderer.captionTracks[r].baseUrl .. '&tlang=' .. lngCodeTr .. '&fmt=vtt'
					 break
					end
				r = r + 1
			end
			if not subtAdr then return end
	 return subtAdr, ' (' .. m_simpleTV.User.YT.Lng.subTr .. ')'
	end
	local function positionToContinue(p)
		if m_simpleTV.User.YT.duration then
			if m_simpleTV.User.YT.duration < 600 and m_simpleTV.User.YT.isMusic == true then
				p = p .. '$OPT:POSITIONTOCONTINUE=0'
			elseif m_simpleTV.User.YT.duration < 300 then
				p = p .. '$OPT:POSITIONTOCONTINUE=0'
			end
		end
	 return p
	end
	local function ItagRemove(z, e)
		for k, v in pairs(z) do
			if v == e then
				table.remove(z, k)
			 return z
			end
		end
	 return z
	end
	local function StreamStart(adrStart)
		local h = adrStart:match('(%d+)h') or 0
		local m = adrStart:match('(%d+)m') or 0
		local s = adrStart:match('(%d+)s') or 0
		local d = adrStart:match('(%d+)') or 0
		local st = (h * 3600) + (m * 60) + s
		if st ~= 0 then
			adrStart = st
		else
			adrStart = d
		end
	 return '$OPT:start-time=' .. adrStart
	end
	local function StreamError(tab, title)
			if not tab.playabilityStatus then
			 return nil, '⚠️ ' .. m_simpleTV.User.YT.Lng.videoNotExst
			end
		local title_err, stream_tab_err
		if tab.playabilityStatus.status == 'LOGIN_REQUIRED'
		then
			title_err = m_simpleTV.User.YT.Lng.noCookies
		elseif tab.playabilityStatus.errorScreen
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason.runs
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason.runs[1]
		then
			local t, i = {}, 1
				for i = 1, #tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason.runs do
					t[i] = {}
					t[i] = tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason.runs[i].text
				end
			title_err = table.concat(t)
		elseif tab.playabilityStatus.errorScreen
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason
			and tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason.simpleText
		then
			title_err = tab.playabilityStatus.errorScreen.playerErrorMessageRenderer.subreason.simpleText
		elseif tab.playabilityStatus.liveStreamability
			and tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer
			and tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer.offlineSlate
			and tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer.offlineSlate.liveStreamOfflineSlateRenderer
			and tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer.offlineSlate.liveStreamOfflineSlateRenderer.mainText
			and tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer.offlineSlate.liveStreamOfflineSlateRenderer.mainText.runs[1]
		then
			local t, i = {}, 1
				for i = 1, #tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer.offlineSlate.liveStreamOfflineSlateRenderer.mainText.runs do
					t[i] = {}
					t[i] = tab.playabilityStatus.liveStreamability.liveStreamabilityRenderer.offlineSlate.liveStreamOfflineSlateRenderer.mainText.runs[i].text
				end
			title_err = table.concat(t)
		else
			title_err = tab.playabilityStatus.reason or m_simpleTV.User.YT.Lng.videoNotAvail
		end
		if not title or title == '' then
			title = ''
		end
		if title_err then
			if title ~= '' then
				title_err = '\nℹ️ ' .. title_err
			else
				title_err = 'ℹ️ ' .. title_err
			end
		end
		title_err = title .. (title_err or '')
		if m_simpleTV.User.YT.pic then
			stream_tab_err = {{Name = '', Address = m_simpleTV.User.YT.pic .. '$OPT:NO-STIMESHIFT$OPT:image-duration=6'}}
		end
	 return stream_tab_err, title_err
	end
	local function DeCipherSign(adr)
			local function table_swap(t, a)
					if a >= #t then return end
				local c = t[1]
				local p = (a % #t) + 1
				t[1] = t[p]
				t[p] = c
			 return t
			end
			local function table_slica(tbl, first, last, step)
				local sliced = {}
				local p = #sliced
					for i = first or 1, last or #tbl, step or 1 do
						p = p + 1
						sliced[p] = tbl[i]
					end
			 return sliced
			end
			local function sign_decode(s, signScr)
				local t = split_str(s)
					if #t == 0 or not signScr then
					 return s
					end
				local math_abs = math.abs
					for i = 1, #signScr do
						local a = signScr[i]
						if a == 0 then
							t = table_reversa(t)
						else
							if a > 0 then
								t = table_swap(t, a)
							else
								t = table_slica(t, math_abs(a) + 1)
							end
						end
					end
			 return table.concat(t)
			end
			if not m_simpleTV.User.YT.signScr then
				ShowInfo('error DeCipherSign', ARGB(255, 153, 0, 0), nil, nil, 0x0102)
			 return	'vlc://pause:5'
			end
			for cipherSign in adr:gmatch('&s=([^&]*)') do
				local signature = sign_decode(cipherSign, m_simpleTV.User.YT.signScr)
				adr = adr:gsub('&s=[^&]*', '&sig=' .. signature, 1)
			end
	 return adr
	end
	local function StreamLive(hls, isLive, title)
		local session = m_simpleTV.Http.New(userAgent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 14000)
		local extOpt = '$OPT:adaptive-use-access'
		local rc, answer = m_simpleTV.Http.Request(session, {url = hls})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then
			 return nil, 'GetStreamsTab live Error 1'
			end
		local t = {}
			for name, fps, adr in answer:gmatch('RESOLUTION=(.-),.-RATE=(%d+).-\n(.-)\n') do
				name = tonumber(name:match('x(%d+)') or '0')
				local qlty
				if name > 240 then
					if tonumber(fps) > 30 then
						qlty = name + 6
						fps = ' ' .. fps .. ' FPS'
					else
						qlty = name
						fps = ''
					end
					t[#t + 1] = {}
					t[#t].Id = #t
					t[#t].Name = name .. 'p' .. fps
					t[#t].Address = adr .. extOpt
					t[#t].qltyLive = qlty
				end
			end
			if #t == 0 then
			 return nil, 'GetStreamsTab live Error 2'
			end
		t[#t + 1] = {}
		t[#t].Id = #t
		t[#t].qltyLive = 10000
		t[#t].Name = '▫ ' .. m_simpleTV.User.YT.Lng.adaptiv
		t[#t].Address = hls .. extOpt
		if isLive == true and not isInfoPanel then
			title = title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.live
		end
	 return t, title
	end
	local function GetQltyIndex(t)
		if (m_simpleTV.User.YT.qlty < 300
			and m_simpleTV.User.YT.qlty > 100)
		then
			m_simpleTV.User.YT.qlty = m_simpleTV.User.YT.qlty0
			or tonumber(m_simpleTV.Config.GetValue('YT_qlty') or '1080')
		end
		local index
			for u = 1, #t do
					if t[u].qltyLive
						and m_simpleTV.User.YT.qlty_live < t[u].qltyLive
					then
					 return index or 1
					end
					if t[u].qlty
						and m_simpleTV.User.YT.qlty < t[u].qlty
					then
					 break
					end
				index = u
			end
		if index == 1
			and m_simpleTV.User.YT.qlty > 100
		then
			if #t > 1 then
				index = 2
			end
		end
	 return index or 1
	end
	local function StreamCheck(t, index)
		local url = t[index].Address
		if t[index].isCipher then
			url = DeCipherSign(url)
		end
			if index == 1
				or (t[index].itag and t[index].itag ~= 22)
			then
			 return url
			end
		local session = m_simpleTV.Http.New(userAgent, nil, true)
			if not session then
			 return url
			end
		m_simpleTV.Http.SetTimeout(session, 14000)
		m_simpleTV.Http.Request(session, {url = url:gsub('$.+',''), method = 'head'})
		local raw = m_simpleTV.Http.GetRawHeader(session)
		m_simpleTV.Http.Close(session)
			if raw:match('Content%-Length: 0') then
				if index > 2 then
					index = index - 1
				elseif #t > index then
					index = index + 1
				else
				 return m_simpleTV.User.YT.logoPicFromDisk .. '$OPT:video-filter=adjust$OPT:saturation=0$OPT:video-filter=gaussianblur$OPT:image-duration=5'
				end
				url = t[index].Address
				if t[index].isCipher then
					url = DeCipherSign(url)
				end
			 return url, index
			end
	 return url
	end
	local function Stream(v, adrStart, aAdr, aItag, aAdr_opus, aItag_opus, captions)
		local adr = StreamFormat(v.Address, v.isCipher)
			.. (adrStart or '')
			.. '$OPT:sub-track=0$OPT:NO-STIMESHIFT$OPT:input-slave='
		if v.isAdaptive == true and aItag then
			local extOpt_demux, adr_audio, itag_audio, adr_captions
			if (aItag_opus and captions)
				and not (v.qlty > 1080 or v.itag == 302 or v.itag == 334)
			then
				adr_audio = aAdr_opus
				itag_audio = aItag_opus
				adr_captions = captions
			else
				adr_audio = aAdr
				itag_audio = aItag
				extOpt_demux = '$OPT:demux=avcodec,any'
			end
			v.aItag = itag_audio
			v.Address = adr .. adr_audio .. (adr_captions or '') .. (extOpt_demux or '')
		else
			v.Address = adr .. (captions or '')
		end
	 return v
	end
	local function GetStreamsTab(vId)
		m_simpleTV.Http.Close(session)
		m_simpleTV.User.YT.ThumbsInfo = nil
		m_simpleTV.User.YT.vId = vId
		m_simpleTV.User.YT.chId = ''
		m_simpleTV.User.YT.title = ''
		m_simpleTV.User.YT.publishedAt = ''
		m_simpleTV.User.YT.actualStartTime = ''
		m_simpleTV.User.YT.duration = nil
		m_simpleTV.User.YT.pic = nil
		m_simpleTV.User.YT.videostats = nil
		m_simpleTV.User.YT.isLive = false
		m_simpleTV.User.YT.isLiveContent = false
		m_simpleTV.User.YT.isTrailer = false
		m_simpleTV.User.YT.desc = ''
		m_simpleTV.User.YT.isMusic = false
		local adrStart = inAdr:match('[?&]t=[^&]*')
		if adrStart and videoId == m_simpleTV.User.YT.vId then
			adrStart = StreamStart(adrStart)
		else
			adrStart = nil
		end
		local session = m_simpleTV.Http.New(userAgent)
			if not session then
			 return nil, 'GetStreamsTab session error 1'
			end
		m_simpleTV.Http.SetTimeout(session, 14000)
		if not m_simpleTV.User.YT.signScr then
			pcall(GetSignScr)
		end
		local referer = urlAdr:match('$OPT:http%-referrer=(.+)') or 'https://music.youtube.com/'
		local url = 'https://www.youtube.com/get_video_info?'
				.. 'eurl=' .. referer
				.. '&hl=' .. m_simpleTV.User.YT.Lng.hl
				.. '&sts=' .. (m_simpleTV.User.YT.sts or '')
				.. '&video_id='
		m_simpleTV.Http.SetCookies(session, url, m_simpleTV.User.YT.cookies, '')
		if infoInFile then
			inf0 = os.clock()
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. m_simpleTV.User.YT.vId})
		if infoInFile then
			inf0 = string.format('%.3f', (os.clock() - inf0))
		end
		answer = answer or ''
		local trailer = answer:match('trailerVideoId%%22%%3A%%22(.-)%%22')
		if trailer then
			m_simpleTV.User.YT.vId = trailer
			m_simpleTV.User.YT.isTrailer = true
			rc, answer = m_simpleTV.Http.Request(session, {url = url .. m_simpleTV.User.YT.vId})
			answer = answer or ''
		end
		if not answer:match('status%%22%%3A%%22OK') then
			if m_simpleTV.User.YT.isAuth then
				m_simpleTV.Http.Close(session)
				session = m_simpleTV.Http.New(userAgent)
					if not session then
					 return nil, 'GetStreamsTab session error 2'
					end
				m_simpleTV.Http.SetTimeout(session, 14000)
			end
			url = 'https://www.youtube.com/get_video_info?'
				.. 'el=detailpage'
				.. '&cco=1'
				.. '&eurl=' .. referer
				.. '&video_id=' .. m_simpleTV.User.YT.vId
				.. '&hl=' .. m_simpleTV.User.YT.Lng.hl
				.. '&sts=' .. (m_simpleTV.User.YT.sts or '')
			m_simpleTV.Http.SetCookies(session, url, m_simpleTV.User.YT.cookies:gsub(';$', '&gl=US;'), '')
			rc, answer = m_simpleTV.Http.Request(session, {url = url})
			answer = answer or ''
		end
		local player_response = answer:match('player_response=([^&]*)')
			if not player_response then
				local httpErr
				if rc == 429 then
					httpErr = 'HTTP Error 429: Too Many Requests\n\n'
							.. m_simpleTV.User.YT.Lng.noCookies
					answer = httpErr
				end
				if infoInFile then
					debug_in_file(answer, m_simpleTV.Common.GetMainPath(2) .. 'YT_player_response.txt', true)
				end
			 return nil, '⚠️ ' .. (httpErr or m_simpleTV.User.YT.Lng.videoNotExst)
			end
		if infoInFile then
			local response = player_response
			response = m_simpleTV.Common.fromPercentEncoding(response)
			response = m_simpleTV.Common.fromPercentEncoding(response)
			response = m_simpleTV.Common.fromPercentEncoding(response)
			response = response:gsub('\\u0026', '&')
			response = response:gsub('++', ' ')
			debug_in_file(response, m_simpleTV.Common.GetMainPath(2) .. 'YT_player_response.txt', true)
		end
			if player_response:match('drmFamilies') then
			 return nil, '⚠️ DRM'
			end
		player_response = player_response:gsub('++', ' ')
		player_response = m_simpleTV.Common.fromPercentEncoding(player_response)
		local err, tab = pcall(lunaJson_decode, player_response)
			if err == false then
				if infoInFile then
					debug_in_file(answer, m_simpleTV.Common.GetMainPath(2) .. 'YT_player_response.txt', true)
				end
			 return nil, 'Json decode error'
			end
			if tab.multicamera
				and m_simpleTV.User.YT.isVideo == true
				and tab.multicamera.playerLegacyMulticameraRenderer
				and tab.multicamera.playerLegacyMulticameraRenderer.metadataList
				and not inAdr:match('&isRestart=true')
				and not inAdr:match('&isPlst=')
				and not inAdr:match('list=')
			then
				local t = {}
				local metadataList = tab.multicamera.playerLegacyMulticameraRenderer.metadataList
				metadataList = m_simpleTV.Common.fromPercentEncoding(metadataList)
					for vId in metadataList:gmatch('/vi/([^/]+)') do
						t[#t + 1] = {}
						t[#t] = vId
					end
					if #t == 0 then
					 return nil, 'no list multicamers'
					end
				t = table.concat(t, ',')
				inAdr = 'https://www.youtube.com/watch_videos?video_ids=' .. t .. '&title=' .. m_simpleTV.User.YT.Lng.camera_plst_title:gsub('%s', '%+')
				inAdr = GetUrlWatchVideos(inAdr)
				m_simpleTV.Http.Close(session)
					if not inAdr then
					 return nil, 'not get adrs multicamers'
					end
				inAdr = inAdr .. '&isLogo=false'
			 return inAdr
			end
		if tab.videoDetails then
			if tab.videoDetails.author then
				m_simpleTV.User.YT.author = tab.videoDetails.author
			end
			if tab.videoDetails.channelId then
				m_simpleTV.User.YT.chId = tab.videoDetails.channelId
			end
			if tab.videoDetails.isLive == true then
				m_simpleTV.User.YT.isLive = true
			end
			if tab.videoDetails.isLiveContent == true then
				m_simpleTV.User.YT.isLiveContent = true
			end
			if tab.videoDetails.lengthSeconds then
				m_simpleTV.User.YT.duration = tonumber(tab.videoDetails.lengthSeconds)
			end
		end
		if tab.microformat
			and tab.microformat.playerMicroformatRenderer
		then
			if m_simpleTV.User.YT.isLive
				and tab.microformat.playerMicroformatRenderer.liveBroadcastDetails
				and tab.microformat.playerMicroformatRenderer.liveBroadcastDetails.startTimestamp
			then
				m_simpleTV.User.YT.isLive = true
				m_simpleTV.User.YT.actualStartTime = tab.microformat.playerMicroformatRenderer.liveBroadcastDetails.startTimestamp
			end
			if m_simpleTV.User.YT.duration == nil
				and tab.microformat.playerMicroformatRenderer.lengthSeconds
			then
				m_simpleTV.User.YT.duration = tonumber(tab.microformat.playerMicroformatRenderer.lengthSeconds)
			end
			if tab.microformat.playerMicroformatRenderer.publishDate then
				m_simpleTV.User.YT.publishedAt = tab.microformat.playerMicroformatRenderer.publishDate
			end
			if tab.microformat.playerMicroformatRenderer.thumbnail
				and tab.microformat.playerMicroformatRenderer.thumbnail.thumbnails
				and tab.microformat.playerMicroformatRenderer.thumbnail.thumbnails[1]
				and tab.microformat.playerMicroformatRenderer.thumbnail.thumbnails[1].url
			then
				m_simpleTV.User.YT.pic = tab.microformat.playerMicroformatRenderer.thumbnail.thumbnails[1].url
			end
			if tab.microformat.playerMicroformatRenderer.category == 'Music' then
				m_simpleTV.User.YT.isMusic = true
			end
			if tab.microformat.playerMicroformatRenderer.description
				and tab.microformat.playerMicroformatRenderer.description.simpleText
				and not tab.microformat.playerMicroformatRenderer.description.simpleText:match('^[%s%c]+$')
			then
				m_simpleTV.User.YT.desc = tab.microformat.playerMicroformatRenderer.description.simpleText
			end
			if tab.microformat.playerMicroformatRenderer.title
				and tab.microformat.playerMicroformatRenderer.title.simpleText
			then
				m_simpleTV.User.YT.title = tab.microformat.playerMicroformatRenderer.title.simpleText
			end
		end
		if tab.videoDetails then
			if m_simpleTV.User.YT.desc == ''
				and tab.videoDetails.shortDescription
				and not tab.videoDetails.shortDescription:match('^[%s%c]+$')
			then
				m_simpleTV.User.YT.desc = tab.videoDetails.shortDescription
			end
			if m_simpleTV.User.YT.title == ''
				and tab.videoDetails.title
			then
				m_simpleTV.User.YT.title = tab.videoDetails.title
			end
		end
		local title = title_clean(m_simpleTV.User.YT.title)
		if tab.multicamera and not isInfoPanel then
			title = title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.camera
		end
		local t, i = {}, 1
		if tab.storyboards
			and tab.storyboards.playerStoryboardSpecRenderer
			and tab.storyboards.playerStoryboardSpecRenderer.spec
		then
			Thumbs(tab.storyboards.playerStoryboardSpecRenderer.spec)
		end
			if tab.streamingData and tab.streamingData.hlsManifestUrl
				and (tab.videoDetails.isLiveContent == true or tab.videoDetails.isLive == true)
			then
				m_simpleTV.Http.Close(session)
			 return StreamLive(tab.streamingData.hlsManifestUrl, tab.videoDetails.isLive, title)
			end
		if tab.streamingData and tab.streamingData.formats then
			local k = 1
				while tab.streamingData.formats[k] do
					t[i] = {}
					t[i].itag = tab.streamingData.formats[k].itag
					t[i].fps = tab.streamingData.formats[k].fps
					t[i].qlty = tab.streamingData.formats[k].height
					t[i].width = tab.streamingData.formats[k].width
					t[i].Address = tab.streamingData.formats[k].url or tab.streamingData.formats[k].signatureCipher
					t[i].isAdaptive = false
					if tab.streamingData.formats[k].signatureCipher then
						t[i].isCipher = true
					end
					k = k + 1
					i = k
				end
		end
		local audioTracks
		if tab.streamingData and tab.streamingData.adaptiveFormats then
			local k = 1
				while tab.streamingData.adaptiveFormats[k] do
					if tab.streamingData.adaptiveFormats[k].contentLength then
						t[i] = {}
						t[i].itag = tab.streamingData.adaptiveFormats[k].itag
						t[i].qlty = tab.streamingData.adaptiveFormats[k].height
						t[i].width = tab.streamingData.adaptiveFormats[k].width
						t[i].fps = tab.streamingData.adaptiveFormats[k].fps
						t[i].Address = tab.streamingData.adaptiveFormats[k].url or tab.streamingData.adaptiveFormats[k].signatureCipher
						t[i].isAdaptive = true
						if tab.streamingData.adaptiveFormats[k].signatureCipher then
							t[i].isCipher = true
						end
						if tab.streamingData.adaptiveFormats[k].audioTrack
							and tab.streamingData.adaptiveFormats[k].audioTrack.audioIsDefault == true
						then
							t[i].audioIsDefault = true
							if not audioTracks then
								audioTracks = true
							end
						end
						i = i + 1
					end
					k = k + 1
				end
		end
			if #t == 0 then
					if urlAdr:match('PARAMS=psevdotv') then return end
				isInfoPanel = false
				m_simpleTV.Http.Close(session)
			 return StreamError(tab, title)
			end
		local captions, captions_title
		local subtitle_config = m_simpleTV.Config.GetValue('subtitle/disableAtStart', 'simpleTVConfig') or 'true'
		if tab.captions
			and tab.captions.playerCaptionsTracklistRenderer
			and tab.captions.playerCaptionsTracklistRenderer.captionTracks
			and subtitle_config == 'true'
		then
			captions, captions_title = Subtitle(tab)
		end
			for i = 1, #t do
				t[i].qlty = tonumber(t[i].qlty or '0')
				t[i].width = tonumber(t[i].width or '0')
				t[i].fps = tonumber(t[i].fps or '0')
				t[i].itag = tonumber(t[i].itag or '0')
				if (t[i].qlty > 340 and t[i].qlty < 500) and t[i].width > 640 then
					t[i].qlty = 480
				end
				if (t[i].qlty > 250 and t[i].qlty < 300) and t[i].width > 600 then
					t[i].qlty = 360
				end
				if (t[i].qlty > 760 and t[i].qlty < 1200) and t[i].width > 1600 then
					t[i].qlty = 1080
				end
				if t[i].qlty > 0 and t[i].qlty <= 180 then
					t[i].qlty = 144
				elseif t[i].qlty > 180 and t[i].qlty <= 300 then
					t[i].qlty = 240
				elseif t[i].qlty > 300 and t[i].qlty <= 400 then
					t[i].qlty = 360
				elseif t[i].qlty > 400 and t[i].qlty <= 500 then
					t[i].qlty = 480
				elseif t[i].qlty > 500 and t[i].qlty <= 780 then
					t[i].qlty = 720
				elseif t[i].qlty > 780 and t[i].qlty <= 1200 then
					t[i].qlty = 1080
				elseif t[i].qlty > 1200 and t[i].qlty <= 1500 then
					t[i].qlty = 1440
				elseif t[i].qlty > 1500 and t[i].qlty <= 2800 then
					t[i].qlty = 2160
				elseif t[i].qlty > 2160 and t[i].qlty < 5000 then
					t[i].qlty = 4320
				else
					t[i].qlty = 0
				end
				t[i].Name = t[i].qlty .. 'p'
				if t[i].fps > 30 then
					t[i].Name = t[i].Name .. ' ' .. t[i].fps .. ' FPS'
					if t[i].itag == 334
						or t[i].itag == 335
						or t[i].itag == 336
						or t[i].itag == 337
					then
						t[i].qlty = t[i].qlty + 7
						t[i].Name = t[i].Name .. ' HDR'
					else
						t[i].qlty = t[i].qlty + 6
					end
				end
			end
		local aAdr, aItag, aAdr_isCipher, aItag_opus, aAdr_opus
		local video_itags = {
							394, 160, 278, -- 144
							395, 133, 242, -- 240
							18, 134, 243, -- 360
							135, 244, -- 480
							136, 247, 22, -- 720
							298, -- 720 (60 fps)
							302, 334, -- 720 (60 fps, HDR)
							137, 248, -- 1080
							299, 335, -- 1080 (60 fps, HDR)
							271, 308, 336, -- 1440 (60 fps, HDR)
							313, 315, 337, -- 2160 (60 fps, HDR)
							272 -- 4320 (60 fps)
							}
		local audio_itags = {
							258, -- MP4 AAC (LC) 384 Kbps Surround (5.1)
							141, -- MP4 AAC (LC) 256 Kbps Stereo (2)
							140, -- MP4 AAC (LC) 128 Kbps Stereo (2)
							251, -- WebM Opus (VBR) ~160 Kbps Stereo (2)
							}
		if (m_simpleTV.User.YT.isVideo == true and m_simpleTV.Control.ChannelID ~= 268435455)
			or m_simpleTV.User.YT.isVideo == false
		then
			video_itags = ItagRemove(video_itags, 22)
		end
		if audioTracks then
			video_itags = ItagRemove(video_itags, 18)
			for i = 1, #audio_itags do
				for z = 1, #t do
					if t[z].audioIsDefault == true then
						if audio_itags[i] == t[z].itag then
							if audio_itags[i] == 251 then
								aAdr_opus = StreamFormat(t[z].Address, t[z].isCipher)
								aItag_opus = t[z].itag
								aAdr_isCipher = t[z].isCipher
							elseif not aItag then
								aAdr = StreamFormat(t[z].Address, t[z].isCipher)
								aItag = t[z].itag
								aAdr_isCipher = t[z].isCipher
							end
						 break
						end
					end
				end
			end
		else
			for i = 1, #audio_itags do
				for z = 1, #t do
					if audio_itags[i] == t[z].itag then
						if audio_itags[i] == 251 then
							aAdr_opus = StreamFormat(t[z].Address, t[z].isCipher)
							aItag_opus = t[z].itag
							aAdr_isCipher = t[z].isCipher
						elseif not aItag then
							aAdr = StreamFormat(t[z].Address, t[z].isCipher)
							aItag = t[z].itag
							aAdr_isCipher = t[z].isCipher
						end
					 break
					end
				end
			end
		end
		local sort = {}
			for i = 1, #video_itags do
				for z = 1, #t do
					if video_itags[i] == t[z].itag then
						sort[#sort + 1] = t[z]
					 break
					end
				end
			end
		if #sort == 0 then
			sort = t
		end
		local hash, noDuplicate = {}, {}
			for i = 1, #sort do
				if not hash[sort[i].Name] then
					noDuplicate[#noDuplicate + 1] = sort[i]
					hash[sort[i].Name] = true
				end
			end
		t = {}
			for i = 1, #noDuplicate do
				if noDuplicate[i].qlty > 300 then
					t[#t + 1] = Stream(noDuplicate[i], adrStart, aAdr, aItag, aAdr_opus, aItag_opus, captions)
				end
			end
		if #t == 0 then
			for i = 1, #noDuplicate do
				t[#t + 1] = Stream(noDuplicate[i], adrStart, aAdr, aItag, aAdr_opus, aItag_opus, captions)
			end
		end
			if #t == 0 then
				m_simpleTV.Http.Close(session)
			 return nil, 'GetStreamsTab Error 2'
			end
		if aAdr then
			local audioItag = tonumber(aAdr:match('itag=(%d+)') or 0)
			if audioItag == 258 then
				aAdr_opus = aAdr
			end
		end
		local aAdrName, audioId, itag_a
		if aAdr_opus or aAdr then
			aAdr = (aAdr_opus or aAdr) .. (adrStart or '') .. '$OPT:NO-STIMESHIFT'
			aAdrName = '🔉 ' .. m_simpleTV.User.YT.Lng.audio
			audioId = 99
			if infoInFile then
				itag_a = aAdr:match('itag=(%d+)')
			end
		else
			aAdr = 'vlc://pause:5'
			aAdrName = '🔇 ' .. m_simpleTV.User.YT.Lng.noAudio
			audioId = 10
		end
		t[#t + 1] = {Name = aAdrName, qlty = audioId, Address = aAdr, isCipher = aAdr_isCipher, aItag = itag_a}
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		inf01 = {}
			for i = 1, #t do
				t[i].Id = i
				if infoInFile then
					if i == 1 then
						inf01[1] = '[1] audio itag = ' .. tostring(t[1].aItag )
					else
						inf01[i] = '[' .. i .. '] qlty: ' .. tostring(t[i].qlty)
								.. ' | video itag: ' .. tostring(t[i].itag) .. ' | audio itag: ' .. tostring(t[i].aItag)
					end
				end
			end
			if infoInFile then
				inf01 = table.concat(inf01, '\n')
			end
		if m_simpleTV.User.YT.qlty < 100 then
			if audioId == 99 and not isInfoPanel then
				title = title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.audio
			else
				title = title .. '\n☐ ' .. m_simpleTV.User.YT.Lng.noAudio
			end
			if not m_simpleTV.User.YT.DelayedAddress then
				local visual = tostring(m_simpleTV.Config.GetValue('vlc/audio/visual/module', 'simpleTVConfig') or '')
				if visual == 'none'
					or visual == ''
				then
					SetBackground(m_simpleTV.User.YT.pic or m_simpleTV.User.YT.logoPicFromDisk)
				else
					SetBackground()
				end
			end
		elseif captions_title and not isInfoPanel then
			title = title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.sub .. captions_title
		end
		if m_simpleTV.User.YT.isAuth
			and m_simpleTV.User.YT.isLive == false
			and m_simpleTV.User.YT.isTrailer == false
			and tab.playbackTracking
			and tab.playbackTracking.videostatsPlaybackUrl
			and tab.playbackTracking.videostatsPlaybackUrl.baseUrl
		then
			m_simpleTV.User.YT.videostats = tab.playbackTracking.videostatsPlaybackUrl.baseUrl
		end
		m_simpleTV.Http.Close(session)
		if m_simpleTV.User.YT.duration
			and m_simpleTV.User.YT.duration > 120
			and m_simpleTV.User.YT.desc ~= ''
			and m_simpleTV.User.YT.desc:match('%d+:%d+')
		then
			Chapters()
		end
	 return t, title
	end
	local function plst_channels(str, tab, typePlst, i)
		local ret = false
		local desc, count, count2, subCount, logo, name, adr
			for g in str:gmatch('"channelRenderer".-"subscribeButton"') do
				name = g:match('"simpleText":"([^"]+)')
				adr = g:match('"channelId":"([^"]+)')
				if name and adr then
					tab[i] = {}
					tab[i].Id = i
					if typePlst == 'channels' then
						tab[i].Address = 'https://www.youtube.com/channel/' .. adr .. '&isLogo=false&isButton=true'
					else
						tab[i].Address = 'https://www.youtube.com/feeds/videos.xml?channel_id=' .. adr .. '&isLogo=false&isRestart=true'
					end
					name = title_clean(name)
					tab[i].Name = name
					if isInfoPanel == true then
						desc = g:match('"descriptionSnippet":{"runs":%[{"text":"([^"]+)')
						count, count2 = g:match('"videoCountText":{"runs":%[{"text":"([^"]+)"},{"text":"([^"]+)')
						subCount = g:match('"subscriberCountText":{"simpleText":"([^"]+)')
						logo = g:match('"thumbnails":%[{"url":"[^%]]+"url":"([^"]+)') or g:match('"thumbnails":%[{"url":"([^"]+)') or ''
						logo = logo:gsub('^//', 'https://')
						tab[i].InfoPanelLogo = logo
						tab[i].InfoPanelShowTime = 10000
						tab[i].InfoPanelName = m_simpleTV.User.YT.Lng.channel .. ': ' .. name
						local panelDescName
						if desc and desc ~= '' then
							panelDescName = m_simpleTV.User.YT.Lng.desc .. ' | '
						end
						tab[i].InfoPanelDesc = desc_html(desc, logo, name, tab[i].Address)
						count = (count or '') .. (count2 or '')
						if subCount and subCount ~= '' then
							if count and count ~= '' then
								subCount = ' | ' .. subCount
							end
						else
							subCount = nil
						end
						tab[i].InfoPanelTitle = (panelDescName or ' ')
											.. (count or '')
											.. (subCount or '')
					end
					i = i + 1
					ret = true
				end
			end
	 return ret
	end
	local function plst_rss(str, tab, typePlst, i)
		local ret = false
		local name, published, adr, desc, panelDescName
			for g in str:gmatch('<entry>.-</entry>') do
				name = g:match('<title>([^<]+)')
				adr = g:match('<yt:videoId>([^<]+)')
				published = g:match('<published>([^<]+)')
				if name and adr and published then
					tab[i] = {}
					tab[i].Id = i
					name = title_clean(name)
					tab[i].Address = string.format('https://www.youtube.com/watch?v=%s&isPlst=true', adr)
					published = timeStamp(published)
					published = os.date('%y %d %m %H %M', tonumber(published))
					local year, day, month, hour, min = published:match('(%d+) (%d+) (%d+) (%d+) (%d+)')
					published = string.format('%d/%d/%02d %d:%02d', day, month, year, hour, min)
					if isInfoPanel == false then
						tab[i].Name = name .. ' (' .. published .. ')'
					else
						tab[i].Name = name
						tab[i].InfoPanelName = name
						tab[i].InfoPanelLogo = string.format('https://i.ytimg.com/vi/%s/default.jpg', adr)
						tab[i].InfoPanelShowTime = 10000
						panelDescName = nil
						desc = g:match('<media:description>([^<]+)')
						tab[i].InfoPanelDesc = desc_html(desc, tab[i].InfoPanelLogo, name, tab[i].Address)
						if desc and desc ~= '' then
							panelDescName = m_simpleTV.User.YT.Lng.desc
						end
						tab[i].InfoPanelTitle = (panelDescName or '') .. ' | ' .. published
					end
					i = i + 1
					ret = true
				end
			end
	 return ret
	end
	local function plst_video(str, tab, typePlst, i)
		local ret = false
		local render
		if typePlst == 'panel_videos' then
			if str:match('"twoColumnBrowseResultsRenderer"') then
				render = 'playlistVideo'
			else
				render = 'playlistPanelVideo'
			end
		else
			if str:match('"gridVideoRenderer"') and str:match('"videoRenderer"') then
				render = '"video'
			else
				render = '[eod]'
			end
		end
		if typePlst == 'main' then
			render = '"video'
		end
		local times, count, publis, channel, name, adr, desc, panelDescName, selected
			for g in str:gmatch(render .. 'Renderer".-"thumbnailOverlayNowPlayingRenderer"') do
				if render == 'playlistPanelVideo' then
					name = g:match('"title".-"simpleText":"([^"]+)')
				else
					name = g:match('"title":%s*{%s*"runs":%s*%[%s*{%s*"text":%s*"([^"]+)') or g:match('"simpleText":%s*"([^"]+)')
				end
				adr = g:match('"videoId":%s*"([^"]+)')
				if name and adr then
					times = g:match('"thumbnailOverlayTimeStatusRenderer".-"simpleText":%s*"([^"]+)')
					name = title_clean(name)
					tab[i] = {}
					tab[i].Id = i
					tab[i].Address = string.format('https://www.youtube.com/watch?v=%s&isPlst=' .. typePlst, adr)
					if isInfoPanel == false then
						if not times then
							times = m_simpleTV.User.YT.Lng.live
						end
						tab[i].Name = string.format('%s [%s]', name, times)
					else
						if times then
							tab[i].Name = name
						else
							times = m_simpleTV.User.YT.Lng.live
							tab[i].Name = string.format('%s [%s]', name, times)
						end
						count = g:match('"shortViewCountText":%s*{%s*"simpleText":%s*"([^"]+)')
								or g:match('iewCountText":%s*{%s*"simpleText":%s*"([^"]+)')
						publis = g:match('"publishedTimeText":%s*{%s*"simpleText":%s*"([^"]+)')
						if count and publis then
							count = publis .. ' ◽ ' .. count
						else
							count = count or publis
						end
						if count then
							count = ' | ' .. count
						else
							count = ''
						end
						channel = g:match('"shortBylineText":%s*{%s*"runs":%s*%[%s*{%s*"text":%s*"([^"]+)')
						if channel then
							channel = ' | ' .. title_clean(channel)
						else
							channel = ''
						end
						desc = g:match('"descriptionSnippet":%s*{%s*"runs":%s*%[%s*{%s*"text":%s*"([^"]+)')
								or g:match('"descriptionSnippet":%s*{%s*"simpleText":%s*"([^"]+)')
						if desc and desc ~= '' then
							panelDescName = m_simpleTV.User.YT.Lng.desc
						else
							panelDescName = ''
						end
						tab[i].InfoPanelLogo = string.format('https://i.ytimg.com/vi/%s/default.jpg', adr)
						tab[i].InfoPanelName = name
						tab[i].InfoPanelDesc = desc_html(desc, tab[i].InfoPanelLogo, name, tab[i].Address)
						if typePlst ~= 'panel_videos' then
							tab[i].InfoPanelTitle = string.format('%s%s%s | %s', panelDescName, count, channel, times)
						else
							tab[i].InfoPanelTitle = string.format('| %s', times)
						end
						tab[i].InfoPanelShowTime = 10000
					end
					if not selected and adr == videoId then
						selected = true
						m_simpleTV.User.YT.plstPos = i
					end
					i = i + 1
					ret = true
				end
			end
	 return ret
	end
	local function AddInPl_Plst_YT(str, tab, typePlst)
		local i = #tab + 1
		local ret = false
		str = str:gsub('\\"', '%%22')
		if typePlst == 'channels'
			or typePlst == 'rss_channels'
		then
			ret = plst_channels(str, tab, typePlst, i)
		elseif typePlst == 'rss_videos'	then
			ret = plst_rss(str, tab, typePlst, i)
		else
			ret = plst_video(str, tab, typePlst, i)
		end
	 return ret
	end
	local function AddInPl_PlstApi_YT(str, tab)
		local i = #tab + 1
		local ret = false
		local selected
		str = str:gsub('\\"', '%%22')
			for name, desc, id in str:gmatch('"title": "([^"]+).-"description": "([^"]*).-"videoId": "([^"]+)') do
				if name ~= 'Deleted video' and name ~= 'Private video' then
					name = title_clean(name)
					tab[i] = {}
					tab[i].Id = i
					if not selected and id == videoId then
						selected = true
						m_simpleTV.User.YT.plstPos = i
					end
					tab[i].Address = string.format('https://www.youtube.com/watch?v=%s&isPlst=true', id)
					if m_simpleTV.User.YT.isPlstsCh == true then
						tab[i].Address = tab[i].Address .. '&isPlstsCh=true'
					end
					tab[i].Name = name
					if isInfoPanel == true then
						tab[i].InfoPanelLogo = string.format('https://i.ytimg.com/vi/%s/default.jpg', id)
						tab[i].InfoPanelName = name
						local panelDescName
						if desc and desc ~= '' then
							panelDescName = m_simpleTV.User.YT.Lng.desc
						end
						tab[i].InfoPanelDesc = desc_html(desc, tab[i].InfoPanelLogo, name, tab[i].Address)
						tab[i].InfoPanelTitle = (panelDescName or ' ')
						tab[i].InfoPanelShowTime = 10000
					end
					i = i + 1
					ret = true
				end
			end
	 return ret
	end
	local function PlstApi(inAdr)
		local plstId = inAdr:match('list=([^&]*)')
		m_simpleTV.User.YT.plstPos = nil
		m_simpleTV.User.YT.isVideo = false
		if not m_simpleTV.User.YT.isPlstsCh then
			m_simpleTV.User.YT.PlstsCh.chTitle = nil
		end
		m_simpleTV.Control.ExecuteAction(37)
		if not m_simpleTV.User.YT.apiKey then
			GetApiKey()
		end
		local url = 'https://www.googleapis.com/youtube/v3/playlists?part=snippet&fields=items/snippet/localized/title&id=' .. plstId .. '&hl=' .. m_simpleTV.User.YT.Lng.hl .. '&key=' .. m_simpleTV.User.YT.apiKey
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = m_simpleTV.User.YT.apiKeyHeader})
		if rc ~= 200 then
			answer = ''
		end
		answer = answer:gsub('\\"', '%%22')
		local header = answer:match('"title": "([^"]+)') or m_simpleTV.User.YT.Lng.plst
		header = title_clean(header)
		m_simpleTV.User.YT.plstHeader = header
		url = 'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&fields=pageInfo&playlistId=' .. plstId .. '&key=' .. m_simpleTV.User.YT.apiKey
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = m_simpleTV.User.YT.apiKeyHeader})
		if rc ~= 200 then
			answer = ''
		end
		local plstTotalResults = tonumber(answer:match('"totalResults": (%d+)') or '1')
		if m_simpleTV.User.YT.isPlstsCh
			and not m_simpleTV.User.YT.is_channel_banner
		then
			SetBackground((m_simpleTV.User.YT.channel_banner or m_simpleTV.User.YT.logoPicFromDisk), 3)
		end
		m_simpleTV.User.YT.is_channel_banner = nil
		local t0 = {}
		t0.url = 'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&fields=nextPageToken,items(snippet/title,snippet/resourceId/videoId,snippet/description)&playlistId=' .. plstId .. '&key=' .. m_simpleTV.User.YT.apiKey
		t0.method = 'get'
		t0.headers = m_simpleTV.User.YT.apiKeyHeader
		local params = {}
		params.Message = '⇩ ' .. m_simpleTV.User.YT.Lng.loading
		params.Callback = AsynPlsCallb_PlstApi_YT
		params.ProgressColor = ARGB(128, 255, 0, 0)
		params.User = {}
		params.User.tab = {}
		params.User.rc = nil
		params.User.plstId = plstId
		params.User.plstTotalResults = plstTotalResults
		params.ProgressEnabled = true
		if plstTotalResults < 301 then
			params.delayedShow = 1500
		end
		asynPlsLoaderHelper.Work(session, t0, params)
		local tab = params.User.tab
		rc = params.User.rc
			if rc == 400 or rc == - 1 then
				StopOnErr(8)
			 return
			end
			if #tab == 0 and rc then
				if rc == 404 and not inAdr:match('&isRestart=true') then
					if plstId:match('^RD') then
						inAdr = 'https://www.youtube.com/watch?v='
							.. plstId:gsub('^RD', '') ..'&list=' .. plstId
					else
						inAdr = inAdr .. '&index=1'
					end
				elseif (rc == 404 or rc == 403) and inAdr:match('&isRestart=true') then
					inAdr = inAdr:gsub('[?&]list=[%w_%-]+', '')
				end
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.ChangeAddress = 'No'
				inAdr = inAdr .. '&isRestart=true'
				if urlAdr:match('&isLogo=false') then
					inAdr = inAdr .. '&isLogo=false'
				end
				m_simpleTV.Control.CurrentAddress = inAdr
				dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
			 return
			end
			if #tab == 0 and not rc then
				StopOnErr(9, m_simpleTV.User.YT.Lng.videoNotAvail)
				if m_simpleTV.User.YT.isPlstsCh == true then
					m_simpleTV.Common.Sleep(2000)
					m_simpleTV.Control.ChangeAddress = 'No'
					m_simpleTV.Control.CurrentAddress = m_simpleTV.User.YT.PlstsCh.MainUrl .. '&isRestart=true'
					dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
				end
			 return
			end
			if not plstPos and videoId and inAdr:match('[?&]t=') then
				inAdr = inAdr:gsub('[?&]list=[%w_%-]+', '')
				m_simpleTV.Http.Close(session)
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = inAdr .. '&isRestart=true'
				dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
			 return
			end
		m_simpleTV.User.YT.Plst = tab
		local plstPos = m_simpleTV.User.YT.plstPos or 1
		local pl = 0
		if plstPos > 1 or inAdr:match('[?&]t=') or #tab == 1 then
			pl = 32
		end
		local FilterType, AutoNumberFormat, Random, PlayMode
		if #tab > 2 then
			if #tab < 15 then
				FilterType = 2
			else
				FilterType = 1
			end
			AutoNumberFormat = '%1. %2'
		else
			FilterType = 2
			AutoNumberFormat = ''
		end
		if plstId:match('^RD') and urlAdr:match('isLogo=false') then
			if #tab > 2 then
				plstPos = math.random(3, #tab)
			end
			pl = 32
			Random = 1
			PlayMode = 1
		else
			Random = - 1
			PlayMode = - 1
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			tab.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_YT()'}
		else
			tab.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_YT()'}
		end
		if m_simpleTV.User.YT.isPlstsCh
		then
			if m_simpleTV.User.paramScriptForSkin_buttonPlst then
				tab.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = 'PlstsCh_YT()'}
			else
				tab.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = 'PlstsCh_YT()'}
			end
		else
			local ButtonScript1 = [[
						m_simpleTV.Control.ExecuteAction(37)
						m_simpleTV.Control.ChangeAddress = 'No'
						m_simpleTV.Control.CurrentAddress = 'https://www.youtube.com/channel/' .. m_simpleTV.User.YT.chId .. '&isRestart=true&isButton=true'
						dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
					]]
			if m_simpleTV.User.paramScriptForSkin_buttonPlst then
				tab.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = ButtonScript1}
			else
				tab.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = ButtonScript1}
			end
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			tab.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		local retAdr
		tab.ExtParams = {}
		tab.ExtParams.FilterType = FilterType
		tab.ExtParams.Random = Random
		tab.ExtParams.PlayMode = PlayMode
		tab.ExtParams.AutoNumberFormat = AutoNumberFormat
		tab.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_YT'
		tab.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_YT'
		tab.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_YT'
		local vId = tab[plstPos].Address:match('watch%?v=([^&]+)')
		if (#tab > 1
			and plstPos == 1)
			or m_simpleTV.User.YT.isPlstsCh
		then
			m_simpleTV.User.YT.DelayedAddress = tab[1].Address
			m_simpleTV.OSD.ShowSelect_UTF8(header, 0, tab, 10000, 2)
			retAdr = 'wait'
		else
			m_simpleTV.OSD.ShowSelect_UTF8(header, plstPos - 1, tab, 10000, pl)
		end
		local t, title = GetStreamsTab(vId)
			if not t or type(t) ~= 'table' then
				StopOnErr(10, title)
			 return
			end
		m_simpleTV.User.YT.QltyTab = t
		local index = GetQltyIndex(t)
		if not retAdr then
			m_simpleTV.Control.CurrentTitle_UTF8 = header .. ' (' .. title:gsub('\n.-$', '') .. ')'
			MarkWatch_YT()
			if infoPanelCheck() == false then
				title = title_is_no_infoPanel(title, t[index].Name)
				ShowMsg(title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.plst)
			end
		end
		m_simpleTV.User.YT.QltyIndex = index
		retAdr = retAdr or StreamCheck(t, index)
		local plstPicId
		if plstId:match('^RD') then
			local plstPicIdRD = plstId:gsub('^RD', '')
			m_simpleTV.User.YT.AddToBaseUrlinAdr = 'https://www.youtube.com/embed?listType=playlist&list=' .. plstId
			plstPicId = plstPicIdRD
			m_simpleTV.User.YT.AddToBaseVideoIdPlst = plstPicIdRD
		else
			m_simpleTV.User.YT.AddToBaseUrlinAdr = 'https://www.youtube.com/playlist?list=' .. plstId
			plstPicId = tab[1].Address:match('watch%?v=([^&]+)')
			m_simpleTV.User.YT.AddToBaseVideoIdPlst = plstPicId
		end
		if #tab == 1 then
			retAdr = positionToContinue(retAdr)
		else
			retAdr = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
		end
		m_simpleTV.Control.CurrentAddress = retAdr
		if m_simpleTV.User.YT.isPlstsCh then
			m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.Control.CurrentAddress})
			m_simpleTV.Control.CurrentTitle_UTF8 = ''
		else
			if m_simpleTV.Control.MainMode == 0 then
				if not urlAdr:match('isLogo=false') and not urlAdr:match('&isRestart=true') then
					m_simpleTV.Control.ChangeChannelLogo(m_simpleTV.User.paramScriptForSkin_logoYT
														or 'https://i.ytimg.com/vi/' .. plstPicId .. '/hqdefault.jpg'
														, m_simpleTV.Control.ChannelID
														, 'CHANGE_IF_NOT_EQUAL')
				end
				if not urlAdr:match('isLogo=false') or urlAdr:match('isSearch=true') then
					m_simpleTV.Control.ChangeChannelName(header, m_simpleTV.Control.ChannelID, false)
				end
			end
			if not urlAdr:match('isLogo=false') then
				m_simpleTV.Control.CurrentTitle_UTF8 = header
			else
				m_simpleTV.Control.SetTitle(header .. ' (' .. title .. ')')
			end
		end
		debug_InfoInFile(infoInFile, retAdr, index, t, noItag22, inf01, inf0, title)
	end
	local function Plst(inAdr)
		m_simpleTV.Control.ExecuteAction(37)
		if not m_simpleTV.User.YT.isPlstsCh then
			m_simpleTV.User.YT.PlstsCh.chTitle = nil
		end
		m_simpleTV.User.YT.isVideo = false
		m_simpleTV.User.YT.plstPos = nil
		if m_simpleTV.User.YT.isPlstsCh
			and not m_simpleTV.User.YT.is_channel_banner
		then
			SetBackground((m_simpleTV.User.YT.channel_banner or m_simpleTV.User.YT.logoPicFromDisk), 3)
		end
		m_simpleTV.User.YT.is_channel_banner = nil
		local url = inAdr:gsub('&is%a+=%a+', '')
		local params = {}
		params.Message = '⇩ ' .. m_simpleTV.User.YT.Lng.loading
		params.Callback = AsynPlsCallb_Plst_YT
		params.ProgressColor = ARGB(128, 255, 0, 0)
		params.User = {}
		params.User.tab = {}
		params.delayedShow = 1800
		params.User.Title = ''
		params.User.First = true
		params.User.setTitle = true
		if inAdr:match('&isPlstsCh=true')
		then
			params.User.setTitle = false
			videoId = m_simpleTV.User.YT.vId
		end
		if url:match('/feed/history') then
			params.User.typePlst = 'history'
		elseif url:match('/feed/channels') then
			params.User.typePlst = 'channels'
		elseif url:match('/feed/rss_channels') then
			params.User.typePlst = 'rss_channels'
		elseif url:match('/feeds/videos%.xml') then
			params.User.typePlst = 'rss_videos'
		elseif url:match('list=')
			and not ((url:match('list=WL')
					or url:match('list=LL')
					or url:match('list=LM'))
						and not url:match('index='))
		then
			params.User.typePlst = 'panel_videos'
		elseif url:match('youtube%.com$') then
			params.User.typePlst = 'main'
		elseif url:match('/feed/subscriptions') then
			params.User.typePlst = 'subscriptions'
		else
			params.User.typePlst = 'true'
		end
		local logo
		if url:match('/feed/subscriptions') then
			url = url:gsub('^(.-/feed/subscriptions).-$', '%1?flow=2')
			logo = 'https://s.ytimg.com/yts/img/favicon_144-vfliLAfaB.png'
		elseif url:match('/feed/history') then
			logo = 'https://s.ytimg.com/yts/img/reporthistory/land-img-vfl_eF5BA.png'
		elseif url:match('/feed/rss_channels') then
			url = url:gsub('rss_', '')
			logo = 'https://s.ytimg.com/yts/img/favicon_144-vfliLAfaB.png'
		elseif url:match('/feed/channels') then
			logo = 'https://s.ytimg.com/yts/img/favicon_144-vfliLAfaB.png'
		elseif url:match('youtube%.com$') then
			logo = 'https://s.ytimg.com/yts/img/favicon_144-vfliLAfaB.png'
		end
		if url:match('list=WL')
			or url:match('list=LL')
			or url:match('list=LM')
		then
			params.ProgressEnabled = true
			params.ProgressColor = ARGB(128, 255, 0, 0)
		end
		local t0 = {}
		t0.url = url
		t0.method = 'get'
		m_simpleTV.Http.SetCookies(session, url, m_simpleTV.User.YT.cookies, '')
		asynPlsLoaderHelper.Work(session, t0, params)
		local header = params.User.Title
		local tab = params.User.tab
			if #tab == 0 then
				StopOnErr(1)
			 return
			end
			if params.User.typePlst == 'channels'
				or params.User.typePlst == 'rss_channels'
			then
				local FilterType, SortOrder, AutoNumberFormat
				if #tab > 1 then
					FilterType = 1
					SortOrder = 1
					AutoNumberFormat = '%1. %2'
				else
					FilterType = 2
					SortOrder = 0
					AutoNumberFormat = ''
				end
				tab.ExtParams = {FilterType = FilterType, SortOrder = SortOrder, AutoNumberFormat = AutoNumberFormat}
				if m_simpleTV.User.paramScriptForSkin_buttonClose then
					tab.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
				else
					tab.ExtButton1 = {ButtonEnable = true, ButtonName = '✕'}
				end
				if m_simpleTV.User.paramScriptForSkin_buttonOk then
					tab.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
				end
				local ret, id = m_simpleTV.OSD.ShowSelect_UTF8(header, -1, tab, 30000, 1 + 4 + 8 + 2)
				m_simpleTV.Control.ExecuteAction(37)
					if not id or ret == 3 then
						m_simpleTV.Control.ExecuteAction(37)
						m_simpleTV.Control.ExecuteAction(11)
					 return
					end
				PlayAddressT_YT(tab[id].Address, false)
				if m_simpleTV.Control.MainMode == 0 then
					logo = m_simpleTV.User.paramScriptForSkin_logoYT or logo
					m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
					m_simpleTV.Control.ChangeChannelName(header, m_simpleTV.Control.ChannelID, false)
				end
			 return
			end
		local plstPos = m_simpleTV.User.YT.plstPos or 1
		m_simpleTV.User.YT.Plst = tab
		m_simpleTV.User.YT.plstHeader = header
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			tab.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_YT()'}
		else
			tab.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_YT()'}
		end
		local FilterType, AutoNumberFormat, pl
		if #tab > 1 then
			FilterType = 1
			AutoNumberFormat = '%1. %2'
			pl = 0
		else
			FilterType = 2
			AutoNumberFormat = ''
			pl = 32
		end
		if plstPos > 1
			or url:match('[?&]t=')
			or #tab == 1
		then
			pl = 32
		end
		if plstPos > 1
			and inAdr:match('&isPlstsCh=true')
		then
			pl = 0
		end
		local ButtonScript1
		if m_simpleTV.User.YT.isPlstsCh
		then
			if m_simpleTV.User.paramScriptForSkin_buttonPlst then
				tab.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = 'PlstsCh_YT()'}
			else
				tab.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = 'PlstsCh_YT()'}
			end
		elseif not inAdr:match('&isPlstsCh=true') then
			local ButtonScript1 = [[
						m_simpleTV.Control.ExecuteAction(37)
						m_simpleTV.Control.ChangeAddress = 'No'
						m_simpleTV.Control.CurrentAddress = 'https://www.youtube.com/channel/' .. m_simpleTV.User.YT.chId .. '&isRestart=true&isButton=true'
						dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
					]]
			if m_simpleTV.User.paramScriptForSkin_buttonPlst then
				tab.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = ButtonScript1}
			else
				tab.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = ButtonScript1}
			end
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			tab.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		local retAdr
		tab.ExtParams = {}
		tab.ExtParams.FilterType = FilterType
		tab.ExtParams.AutoNumberFormat = AutoNumberFormat
		tab.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_YT'
		tab.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_YT'
		tab.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_YT'
		local vId = tab[plstPos].Address:match('v=([^&]+)')
		m_simpleTV.User.YT.AddToBaseUrlinAdr = url
		m_simpleTV.User.YT.AddToBaseVideoIdPlst = vId
		if #tab > 1
			and plstPos == 1
		then
			m_simpleTV.User.YT.DelayedAddress = tab[1].Address
			m_simpleTV.OSD.ShowSelect_UTF8(header, 0, tab, 10000, 2)
			retAdr = 'wait'
		else
			m_simpleTV.OSD.ShowSelect_UTF8(header, plstPos - 1, tab, 10000, pl)
		end
		local t, title = GetStreamsTab(vId)
			if not t or type(t) ~= 'table' then
				StopOnErr(2, title)
			 return
			end
		m_simpleTV.User.YT.QltyTab = t
		local index = GetQltyIndex(t)
		if not retAdr then
			m_simpleTV.Control.CurrentTitle_UTF8 = header .. ' (' .. title:gsub('\n.-$', '') .. ')'
			MarkWatch_YT()
			if infoPanelCheck() == false then
				title = title_is_no_infoPanel(title, t[index].Name)
				ShowMsg(title .. '\n☑ ' .. m_simpleTV.User.YT.Lng.plst)
			end
		else
			m_simpleTV.Control.CurrentTitle_UTF8 = header
		end
		m_simpleTV.User.YT.QltyIndex = index
		retAdr = retAdr or StreamCheck(t, index)
		if #tab == 1 then
			retAdr = positionToContinue(retAdr)
		else
			retAdr = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
		end
		m_simpleTV.Control.CurrentAddress = retAdr
		if m_simpleTV.User.YT.isPlstsCh then
			m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.Control.CurrentAddress})
		else
			if m_simpleTV.Control.MainMode == 0 then
				logo = m_simpleTV.User.paramScriptForSkin_logoYT
						or logo
						or 'https://i.ytimg.com/vi/' .. vId .. '/hqdefault.jpg'
				m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
				m_simpleTV.Control.ChangeChannelName(header, m_simpleTV.Control.ChannelID, false)
			end
		end
		debug_InfoInFile(infoInFile, retAdr, index, t, noItag22, inf01, inf0, title)
	end
	local function PlstsCh(inAdr)
			if (m_simpleTV.Control.Reason == 'Stopped' or m_simpleTV.Control.Reason == 'EndReached')
				and
				(inAdr:match('isPlstsCh=true') or (inAdr:match('&isRestart=true') and not inAdr:match('/youtubei/') and not inAdr:match('&sort=.-&isRestart=true')))
			then
				m_simpleTV.Control.ExecuteAction(63)
			 return
			end
		local url = inAdr
		if url:match('/live$') or url:match('/embed/live_stream') then
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then
					StopOnErr(3)
				 return
				end
			if inAdr:match('/live$') then
				liveId = answer:match('"liveStreamabilityRenderer":{"videoId":"([^"]+)')
			else
				liveId = answer:match('"watchEndpoint\\":{\\"videoId\\":\\"([^\\]+)')
			end
				if liveId then
					m_simpleTV.Http.Close(session)
					m_simpleTV.Control.ChangeAddress = 'No'
					m_simpleTV.Control.CurrentAddress = 'https://www.youtube.com/watch?v=' .. liveId .. '&isRestart=true'
					dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
				 return
				end
			url = url:gsub('/live$', '')
			url = url:gsub('embed/live_stream%?channel=', 'channel/')
		end
		local onButton = url:match('&isButton=true')
		local youtubei = url:match('/youtubei/')
		url = url:gsub('&is%a+=%a+', '') .. '&isRestart=true'
		if onButton then
			url = url .. '&isButton=true'
			url = url:gsub('%?view=1$', '?view=1&sort=dd&shelf_id=0')
		end
		if not youtubei and not url:match('/playlists') then
			url = url:gsub('/?$', '') .. '/playlists'
		end
		if not url:match('sort=') and not youtubei then
			url = url:gsub('^(.-/playlists).-$', '%1')
			if onButton then
				url = url .. '?view=1&sort=lad&shelf_id=0'
			end
		end
		if not m_simpleTV.User.YT.PlstsCh.MainUrl then
			m_simpleTV.User.YT.PlstsCh.MainUrl = url
		end
		if #m_simpleTV.User.YT.PlstsCh.Urls > 0 then
			if m_simpleTV.User.YT.PlstsCh.MainUrl == url then
				m_simpleTV.User.YT.PlstsCh.Urls = nil
				m_simpleTV.User.YT.PlstsCh.FirstUrl = nil
				m_simpleTV.User.YT.PlstsCh.Num = nil
				m_simpleTV.User.YT.upLoadOnCh = false
			end
		end
		if m_simpleTV.User.YT.PlstsCh.MainUrl ~= url then
			if not youtubei then
				m_simpleTV.User.YT.PlstsCh.MainUrl = url
				m_simpleTV.User.YT.PlstsCh.Urls = nil
				m_simpleTV.User.YT.PlstsCh.FirstUrl = nil
				m_simpleTV.User.YT.PlstsCh.Num = nil
			end
		end
		if not m_simpleTV.User.YT.PlstsCh.Urls then
			m_simpleTV.User.YT.PlstsCh.Urls = {}
		end
		local num = 0
		local method = 'get'
		local body = ''
		if youtubei then
			method = 'post'
			body = m_simpleTV.User.YT.PlstsCh.body
			url, num = url:match('^(.-)&numVideo=(%d+)')
				if not url or not num then
					StopOnErr(3.1)
				 return
				end
			body = url:match('body=([^&]*)') or ''
			body = decode64(body)
		end
		if not youtubei then
			m_simpleTV.User.YT.PlstsCh.visitorData = nil
		end
		local headers = 'X-Origin: https://www.youtube.com\nContent-Type: application/json\nX-Youtube-Client-Name: 1\nX-YouTube-Client-Version: 2.20210302.07.01\nX-Goog-Visitor-Id: ' .. (m_simpleTV.User.YT.PlstsCh.visitorData or '') .. header_Auth()
		m_simpleTV.Http.SetCookies(session, url, m_simpleTV.User.YT.cookies, '')
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, method = method, url = url:gsub('&isRestart=true', ''):gsub('&isButton=true', ''), headers = headers})
			if rc ~= 200 then
				StopOnErr(4, 'cant load channal page')
			 return
			end
		answer = answer:gsub('\\"', '%%22')
		answer = answer:gsub('\\/', '/')
		if not youtubei then
			m_simpleTV.User.YT.PlstsCh.visitorData = answer:match('"visitorData":"([^"]+)') or ''
		end
		local chTitle = answer:match('channelMetadataRenderer.-"title":%s*"([^"]+)')
					or answer:match('"topicChannelDetailsRenderer":{"title":%s*{%s*"simpleText":"([^"]+)')
					or 'Playlists'
		chTitle = title_clean(chTitle)
		local channel_banner = answer:match('"tvBanner":{"thumbnails":%[.-:480},{"url":"(.-)%-fcrop')
		local channel_avatar = answer:match('"thumbnails":%[{"url":"[^%]]+"url":"([^"]+)') or answer:match('"avatar":{"thumbnails":%[{"url":"([^"]+)')
		if channel_banner then
			channel_banner = channel_banner:gsub('^//', 'https://')
		end
		if channel_avatar then
			channel_avatar = channel_avatar:gsub('^//', 'https://')
		end
		if not youtubei and not inAdr:match('&isRestart=true') then
			SetBackground(channel_banner or m_simpleTV.User.YT.logoPicFromDisk)
			m_simpleTV.Control.SetTitle(chTitle)
			m_simpleTV.User.YT.is_channel_banner = true
		end
		if not youtubei then
			m_simpleTV.User.YT.channel_banner = channel_banner
		end
		local buttonNext = false
		local continuation = answer:match('"continuation":%s*"([^"]+)') or answer:match('"continuationCommand":%s*{%s*"token":%s*"([^"]+)')
		if continuation then
			url = 'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8			&body=' .. encode64('{"context":{"client":{"clientName":"WEB","clientVersion":"2.20201021.03.00","hl":"' .. m_simpleTV.User.YT.Lng.hl ..'",}},"continuation":"' .. continuation .. '"}')
			buttonNext = true
		end
		answer = answer:gsub('"title":%s*{%s*"simpleText"', '"text"')
		answer = answer:gsub('{', '')
		answer = answer:gsub('}', '')
		local chId
		if not youtubei then
			chId = inAdr:match('/channel/([^/]+)') or answer:match('"browseId":"([^"]+)')
		end
		local tab, i = {}, 1
		local j = 1 + tonumber(num)
		local shelf = inAdr:match('shelf_id=(%d+)') or '0'
		if chId and onButton then
			if not m_simpleTV.User.YT.apiKey then
				GetApiKey()
			end
			if m_simpleTV.User.YT.apiKey then
					local function PlstTotalResults()
						local plstId = string.format('UU%s', chId:sub(3))
						local url = string.format('https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&fields=pageInfo&playlistId=%s&key=%s', plstId, m_simpleTV.User.YT.apiKey)
						local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = m_simpleTV.User.YT.apiKeyHeader})
							if rc ~= 200 then return end
						local plstTotalResults = tonumber(answer:match('"totalResults": (%d+)') or '0')
							if plstTotalResults > 0 then
								local t = {}
								t[1] = {}
								t[1].Id = 1
								t[1].Address = string.format('https://www.youtube.com/playlist?list=%s&isPlstsCh=true', plstId)
								t[1].Name = string.format('🔺 %s (%s)', m_simpleTV.User.YT.Lng.upLoadOnCh, plstTotalResults)
								t[1].count = plstTotalResults
								if isInfoPanel == true then
									t[1].InfoPanelLogo = channel_avatar or channel_banner or m_simpleTV.User.YT.logoPicFromDisk
									t[1].InfoPanelShowTime = 10000
									t[1].InfoPanelName = m_simpleTV.User.YT.Lng.channel .. ': ' .. chTitle
									t[1].InfoPanelDesc = desc_html(nil, t[1].InfoPanelLogo, m_simpleTV.User.YT.Lng.upLoadOnCh .. ' ' .. chTitle, t[1].Address)
									t[1].InfoPanelTitle = ' | ' .. m_simpleTV.User.YT.Lng.plst 	.. ': '
											.. m_simpleTV.User.YT.Lng.upLoadOnCh
											.. ' ('	.. plstTotalResults .. ' ' .. m_simpleTV.User.YT.Lng.video .. ')'
								end
							 return t
							end
					 return
					end
				local plstTotalResults = PlstTotalResults()
				if plstTotalResults then
					tab = plstTotalResults
					i = 2
					m_simpleTV.User.YT.upLoadOnCh = true
				end
			end
		end
		if m_simpleTV.User.YT.upLoadOnCh and j > 1 then
			j = j - 1
		end
			for adr, logo, name, count in answer:gmatch('listRenderer":%s*"playlistId":%s*"([^"]+).-"thumbnails":%s*%[%s*"url":%s*"([^"]+).-"text":%s*"([^"]+).-"videoCountShortText":%s*"simpleText":%s*"([^"]+)') do
				tab[i] = {}
				tab[i].Id = i
				tab[i].count = count or '0'
				name = title_clean(name)
				tab[i].Name = j .. '. ' .. name .. ' (' .. count .. ')'
				tab[i].Address = string.format('https://www.youtube.com/playlist?list=%s&isPlstsCh=true', adr)
				if isInfoPanel == true then
					logo = logo:gsub('hqdefault', 'default')
					logo = logo:gsub('^//', 'https://')
					logo = logo:gsub('/vi_webp/', '/vi/')
					logo = logo:gsub('movieposter%.webp', 'default.jpg')
					tab[i].InfoPanelLogo = logo
					tab[i].InfoPanelShowTime = 10000
					tab[i].InfoPanelName = m_simpleTV.User.YT.Lng.channel .. ': ' .. chTitle
					tab[i].InfoPanelDesc = desc_html(nil, logo, name, tab[i].Address)
					tab[i].InfoPanelTitle = ' | ' .. m_simpleTV.User.YT.Lng.plst .. ': '
											.. name
											.. ' (' .. count .. ' ' .. m_simpleTV.User.YT.Lng.video .. ')'
				end
				j = j + 1
				i = i + 1
			end
			if #tab == 0 then
				for w in answer:gmatch('"itemSectionRenderer":%s*".-"thumbnails":%s*%[%s*"url":%s*"[^"]+') do
					name = w:match('"title":%s*"runs":%s*%[%s*"text":%s*"([^"]+)')
					adr = w:match('"webCommandMetadata":%s*"url":%s*"([^"]+)')
						if not adr or not name then break end
					tab[i] = {}
					tab[i].Id = i
					name = title_clean(name)
					tab[i].Name = j .. '. ' .. name
					tab[i].Address = string.format('https://www.youtube.com%s&isPlstsCh=true', adr)
					if isInfoPanel == true then
						logo = w:match('"thumbnails":%s*%[%s*"url":%s*"([^"]+)') or ''
						logo = logo:gsub('hqdefault', 'default')
						logo = logo:gsub('^//', 'https://')
						logo = logo:gsub('/vi_webp/', '/vi/')
						logo = logo:gsub('movieposter%.webp', 'default.jpg')
						tab[i].InfoPanelLogo = logo
						tab[i].InfoPanelShowTime = 10000
						tab[i].InfoPanelName = m_simpleTV.User.YT.Lng.channel .. ': ' .. chTitle
						tab[i].InfoPanelDesc = desc_html(nil, logo, name, tab[i].Address)
						tab[i].InfoPanelTitle = ' | ' .. m_simpleTV.User.YT.Lng.plst .. ': ' .. name
					end
					j = j + 1
					i = i + 1
				end
				buttonNext = false
			end
				if #tab == 0 and inAdr:match('&numVideo=') then
					PrevPlstsCh_YT()
				 return
				elseif #tab == 0 then
					inAdr = inAdr:gsub('/playlists.-$', '') .. '&isPlstsCh=true'
					Plst(inAdr)
				 return
				end
		m_simpleTV.User.YT.ChTitle = chTitle
		m_simpleTV.User.YT.PlstsChTab = tab
		m_simpleTV.User.YT.isPlstsCh = true
		local buttonPrev = false
		if #m_simpleTV.User.YT.PlstsCh.Urls >= 1 then
			buttonPrev = true
		end
		if m_simpleTV.User.paramScriptForSkin_buttonPrev then
			tab.ExtButton0 = {ButtonEnable = buttonPrev, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPrev}
		else
			tab.ExtButton0 = {ButtonEnable = buttonPrev, ButtonName = '🢀'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonNext then
			tab.ExtButton1 = {ButtonEnable = buttonNext, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonNext}
		else
			tab.ExtButton1 = {ButtonEnable = buttonNext, ButtonName = '🢂'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			tab.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		num = #tab + tonumber(num)
		local nom1PlstsChTab = tonumber(tab[1].Name:match('^(%d+)') or '1')
		if nom1PlstsChTab == 1 then
			m_simpleTV.User.YT.Nom1PlstsChTab = 1
			m_simpleTV.User.YT.pagePlstsCh = 1
		end
		if nom1PlstsChTab > m_simpleTV.User.YT.Nom1PlstsChTab then
			m_simpleTV.User.YT.pagePlstsCh = m_simpleTV.User.YT.pagePlstsCh + 1
		end
		if nom1PlstsChTab < m_simpleTV.User.YT.Nom1PlstsChTab then
			m_simpleTV.User.YT.pagePlstsCh = m_simpleTV.User.YT.pagePlstsCh - 1
		end
		m_simpleTV.User.YT.Nom1PlstsChTab = nom1PlstsChTab
		if m_simpleTV.User.YT.pagePlstsCh > 1 then
			m_simpleTV.User.YT.ChTitle = m_simpleTV.User.YT.ChTitle .. ' (' .. m_simpleTV.User.YT.Lng.page .. ' ' .. m_simpleTV.User.YT.pagePlstsCh .. ')'
		end
		url = url .. '&numVideo=' .. num
		table.insert(m_simpleTV.User.YT.PlstsCh.Urls, url)
		if not m_simpleTV.User.YT.PlstsCh.FirstUrl then
			m_simpleTV.User.YT.PlstsCh.FirstUrl = url
		end
		if not m_simpleTV.User.YT.PlstsCh.Num then
			m_simpleTV.User.YT.PlstsCh.Num = 0
		end
		local index = 0
		if m_simpleTV.User.YT.PlstsCh.Refresh then
			index = 0
		end
		num = m_simpleTV.User.YT.PlstsCh.Num
			for k, v in ipairs(tab) do
				if tonumber(num) == tonumber(v.Name:match('^(%d+)')) then
					index = k
				end
			end
		tab.ExtParams = {FilterType = 2, LuaOnCancelFunName = 'OnMultiAddressCancel_YT'}
		m_simpleTV.User.YT.PlstsCh.chTitle = chTitle
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('📋 ' .. m_simpleTV.User.YT.ChTitle, index - 1, tab, 30000, 1 + 4 + 8 + 2 + 128)
		m_simpleTV.Control.CurrentTitle_UTF8 = chTitle
		if m_simpleTV.Control.MainMode == 0 then
			if not (inAdr:match('&isRestart=true') or youtubei) then
				m_simpleTV.Control.ChangeChannelLogo(m_simpleTV.User.paramScriptForSkin_logoYT
										or channel_avatar
										or channel_banner
										or m_simpleTV.User.YT.logoPicFromDisk
										, m_simpleTV.Control.ChannelID
										, 'CHANGE_IF_NOT_EQUAL')
				m_simpleTV.Control.ChangeChannelName(m_simpleTV.User.YT.ChTitle, m_simpleTV.Control.ChannelID, false)
			end
		end
			if not id then
				m_simpleTV.Control.ExecuteAction(37)
				m_simpleTV.Http.Close(session)
			 return
			end
			if ret == 1 then
				m_simpleTV.User.YT.PlstsCh.Num = tab[id].Name:match('^(%d+)') or tab[1].Name
				m_simpleTV.User.YT.PlstsCh.Header = tab[id].Name:match('^%d+%. (.+)') or tab[1].Name
				m_simpleTV.User.YT.PlstsCh.Refresh = false
				PlstApi(tab[id].Address)
			 return
			end
			if ret == 2 then
				PrevPlstsCh_YT()
			 return
			end
			if ret == 3 then
				NextPlstsCh_YT()
			 return
			end
	end
	local function Video()
		local t, title = GetStreamsTab(videoId)
			if not t then
				StopOnErr(12, title)
			 return
			end
			if type(t) ~= 'table' then
				PlayAddressT_YT(t)
			 return
			end
		m_simpleTV.User.YT.QltyTab = t
		local index = GetQltyIndex(t)
		local retAdr, noItag22 = StreamCheck(t, index)
		m_simpleTV.User.YT.QltyIndex = index
		if m_simpleTV.User.YT.isVideo == true then
			local name = title:gsub('%c.-$', '')
			if not (m_simpleTV.User.YT.isLive
				and m_simpleTV.Control.ChannelID ~= 268435455)
			then
				if m_simpleTV.Control.MainMode == 0 then
					m_simpleTV.Control.ChangeChannelLogo('https://i.ytimg.com/vi/'
													.. m_simpleTV.User.YT.vId .. '/hqdefault.jpg'
													, m_simpleTV.Control.ChannelID
													, 'CHANGE_IF_NOT_EQUAL')
					m_simpleTV.Control.ChangeChannelName(name, m_simpleTV.Control.ChannelID, false)
				end
			end
			m_simpleTV.Control.SetTitle(name)
			m_simpleTV.Control.CurrentTitle_UTF8 = name
			local header, name_header, ap_header, desc, panelDescName
			local publishedAt = ''
			if m_simpleTV.User.YT.author
				and m_simpleTV.User.YT.isTrailer == false
			then
				name_header = m_simpleTV.User.YT.Lng.upLoadOnCh
						.. ': '
						.. m_simpleTV.User.YT.author
			elseif m_simpleTV.User.YT.isTrailer == true then
				name_header = m_simpleTV.User.YT.Lng.preview
			else
				name_header = ''
			end
			if m_simpleTV.User.YT.isLive == true then
				if isInfoPanel == false then
					ap_header = ' (' .. m_simpleTV.User.YT.Lng.live .. ')'
				else
					if m_simpleTV.User.YT.actualStartTime then
						local timeSt = timeStamp(m_simpleTV.User.YT.actualStartTime)
						timeSt = os.date('%y %d %m %H %M', tonumber(timeSt))
						local year, day, month, hour, min = timeSt:match('(%d+) (%d+) (%d+) (%d+) (%d+)')
						publishedAt = ' | ' .. m_simpleTV.User.YT.Lng.started .. ': '
								.. string.format('%d:%02d (%d/%d/%02d)', hour, min, day, month, year)
					end
				end
			else
				if isInfoPanel == false then
					if m_simpleTV.User.YT.duration and m_simpleTV.User.YT.duration > 2 then
						ap_header = ' (' .. secondsToClock(m_simpleTV.User.YT.duration) .. ')'
					end
				end
			end
			local t1 = {}
			t1[1] = {}
			t1[1].Id = 1
			t1[1].Address = 'https://www.youtube.com/watch?v=' .. m_simpleTV.User.YT.vId
			t1[1].Name = name
			if isInfoPanel == false then
				header = name_header .. (ap_header or '')
			else
				if m_simpleTV.User.YT.isTrailer == true then
					ap_header = m_simpleTV.User.YT.Lng.preview
				elseif m_simpleTV.User.YT.isLive == true then
					ap_header = m_simpleTV.User.YT.Lng.live
				else
					ap_header = m_simpleTV.User.YT.Lng.video
				end
				if m_simpleTV.User.YT.isLive == false then
					if m_simpleTV.User.YT.duration and m_simpleTV.User.YT.duration > 2 then
						publishedAt = ' | ' .. secondsToClock(m_simpleTV.User.YT.duration)
					end
				end
				header = 'YouTube - ' .. ap_header
				t1[1].InfoPanelLogo = 'https://i.ytimg.com/vi/' .. m_simpleTV.User.YT.vId .. '/default.jpg'
				t1[1].InfoPanelName = name
				t1[1].InfoPanelShowTime = 8000
				desc = m_simpleTV.User.YT.desc
				panelDescName = nil
				if desc and desc ~= '' then
					panelDescName = m_simpleTV.User.YT.Lng.desc .. ' | '
				end
				t1[1].InfoPanelDesc = desc_html(desc, t1[1].InfoPanelLogo, name, t1[1].Address)
				t1[1].InfoPanelTitle = (panelDescName or '')
									.. m_simpleTV.User.YT.Lng.channel .. ': '
									.. title_clean(m_simpleTV.User.YT.author)
									.. publishedAt
			end
			if m_simpleTV.User.YT.isLiveContent == false
				and m_simpleTV.User.YT.isTrailer == false
			then
				t1[2] = {}
				t1[2].Id = 2
				t1[2].Name = '🔎 ' .. m_simpleTV.User.YT.Lng.search .. ': ' .. m_simpleTV.User.YT.Lng.relatedVideos
				t1[2].Address = '-related=' .. m_simpleTV.User.YT.vId .. '&isLogo=false'
				if m_simpleTV.User.YT.isMusic == true then
					t1[3] = {}
					t1[3].Id = 3
					t1[3].Name = '🎵🔀 Music-Mix ' .. m_simpleTV.User.YT.Lng.plst
					t1[3].Address = 'https://www.youtube.com/embed?listType=playlist&list=RD'
									.. m_simpleTV.User.YT.vId
									.. '&isLogo=false'
					m_simpleTV.User.YT.PlstsCh.chTitle = nil
				end
			end
			t1.ExtParams = {FilterType = 2, LuaOnCancelFunName = 'OnMultiAddressCancel_YT'}
			if m_simpleTV.User.paramScriptForSkin_buttonOptions then
				t1.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'Qlty_YT()'}
			else
				t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_YT()'}
			end
			local ButtonScript1 = [[
						m_simpleTV.Control.ExecuteAction(37)
						m_simpleTV.Control.ChangeAddress = 'No'
						m_simpleTV.Control.CurrentAddress = 'https://www.youtube.com/channel/' .. m_simpleTV.User.YT.chId .. '&isRestart=true&isButton=true'
						dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
					]]
			if m_simpleTV.User.paramScriptForSkin_buttonPlst then
				t1.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = ButtonScript1}
			else
				t1.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = ButtonScript1}
			end
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t1.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			m_simpleTV.OSD.ShowSelect_UTF8(header, 0, t1, 8000, 32 + 64 + 128)
			retAdr = positionToContinue(retAdr)
		else
			if urlAdr:match('PARAMS=psevdotv') then
				local t = m_simpleTV.Control.GetCurrentChannelInfo()
				if t and t.MultiHeader then
					title = t.MultiHeader .. ': ' .. title
				end
				local name = title:gsub('%c.-$', '')
				m_simpleTV.Control.SetTitle(name)
				retAdr = retAdr .. '$OPT:NO-SEEKABLE'
			else
				m_simpleTV.Control.CurrentTitle_UTF8 = ''
			end
			retAdr = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
		end
		MarkWatch_YT()
		if isInfoPanel == false then
			title = title_is_no_infoPanel(title, t[index].Name)
			ShowMsg(title)
		end
		m_simpleTV.Http.Close(session)
		m_simpleTV.Control.CurrentAddress = retAdr
		debug_InfoInFile(infoInFile, retAdr, index, t, noItag22, inf01, inf0, title)
	end
	function AsynPlsCallb_Plst_YT(session, rc, answer, userstring, params)
		local ret = {}
			if rc ~= 200 then
				ret.Cancel = true
			 return ret
			end
		if params.User.First == true then
			answer = answer:gsub('\\"', '%%22')
			params.User.headers = 'X-Origin: https://www.youtube.com\nContent-Type: application/json\nX-Youtube-Client-Name: 1\nX-YouTube-Client-Version: 2.20210302.07.01' .. '\nX-Goog-Visitor-Id: ' .. (answer:match('"visitorData":"([^"]+)') or '') .. header_Auth()
			params.User.First = false
			local title
			if params.User.typePlst == 'rss_videos'	then
				title = (answer:match('<title>([^<]+)') or '')
			else
				title = answer:match('MetadataRenderer":{"title":"([^"]+)')
								or answer:match('"playlist":{"playlist":{"title":"([^"]+)')
								or answer:match('"hashtagHeaderRenderer":{"hashtag":{"simpleText":"([^"]+)')
								or answer:match('"subFeedOptionRenderer":{"name":{"runs":%[{"text":"([^"]+)')
								or answer:match('HeaderRenderer":{"title":{"simpleText":"([^"]+)')
								or answer:match('HeaderRenderer":{"title":{"runs":%[{"text":"([^"]+)')
								or answer:match('HeaderRenderer":{"title":"([^"]+)')
								or answer:match('"topicChannelDetailsRenderer":{"title":{"simpleText":"([^"]+)')
								or 'not found title'
			end
			title = title_clean(title)
			if m_simpleTV.User.YT.isAuth and inAdr:match('list=LM') then
				title = title .. ' 🎵'
			end
			if params.User.typePlst ~= 'true'
				and params.User.typePlst ~= 'panel_videos'
			then
				if params.User.typePlst:match('rss_') then
					title = '[RSS Feed] ' .. title
				end
				title = 'YouTube - ' .. title
			end
			if params.User.setTitle == true then
				m_simpleTV.Control.SetTitle(m_simpleTV.User.YT.PlstsCh.chTitle or title)
			end
			params.User.Title = title
			if params.ProgressEnabled == true then
				params.User.plstTotalResults = answer:match('"stats":%[{"runs":%[{"text":"(%d+)')
			end
		end
			if not AddInPl_Plst_YT(answer, params.User.tab, params.User.typePlst) then
				ret.Done = true
			 return ret
			end
		local continuation = answer:match('"continuation":%s*"([^"]+)') or answer:match('"continuationCommand":%s*{%s*"token":%s*"([^"]+)')
			if not continuation then
				ret.Done = true
			 return ret
			end
		ret.request = {}
		ret.request.url = 'https://www.youtube.com/youtubei/v1/browse?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8'
		ret.request.method = 'post'
		ret.request.body = '{"context":{"client":{"clientName":"WEB","clientVersion":"2.20210302.07.01","hl":"' .. m_simpleTV.User.YT.Lng.hl ..'",}},"continuation":"' .. continuation .. '"}'
		ret.request.headers = params.User.headers
		ret.Count = #params.User.tab
		if params.User.plstTotalResults then
			ret.Progress = ret.Count / tonumber(params.User.plstTotalResults)
		end
	 return ret
	end
	function AsynPlsCallb_PlstApi_YT(session, rc, answer, userstring, params)
		local ret = {}
			if rc ~= 200 then
				params.User.rc = rc
				ret.Cancel = true
			 return ret
			end
			if not AddInPl_PlstApi_YT(answer, params.User.tab) then
				ret.Done = true
			 return ret
			end
		local nextPageToken = answer:match('"nextPageToken": "([^"]+)')
			if not nextPageToken then
				ret.Done = true
			 return ret
			end
		ret.request = {}
		ret.request.url = string.format('https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&fields=nextPageToken,items(snippet/title,snippet/resourceId/videoId,snippet/description)&playlistId=%s&key=%s&pageToken=%s', params.User.plstId, m_simpleTV.User.YT.apiKey, nextPageToken)
		ret.request.headers = m_simpleTV.User.YT.apiKeyHeader
		ret.Count = #params.User.tab
		ret.Progress = ret.Count / params.User.plstTotalResults
	 return ret
	end
	function PositionThumbs_YT(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.YT.ThumbsInfo then
				 return true
				end
			local imgLen = m_simpleTV.User.YT.ThumbsInfo.samplingFrequency * m_simpleTV.User.YT.ThumbsInfo.thumbsPerImage
			local index = math.floor(forTime / imgLen)
			local t = {}
			t.playAddress = address
			local NPattern = m_simpleTV.User.YT.ThumbsInfo.NPattern:gsub('$M', index)
			t.url = m_simpleTV.User.YT.ThumbsInfo.urlPattern:gsub('$N', NPattern)
			t.httpParams = {}
			t.httpParams.userAgent = userAgent
			t.httpParams.extHeader = 'Referer: https://www.youtube.com/'
			t.elementWidth = m_simpleTV.User.YT.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.YT.ThumbsInfo.thumbHeight
			t.startTime = index * imgLen
			t.length = imgLen
			t.marginLeft = 0
			t.marginRight = 3
			t.marginTop = 0
			t.marginBottom = 0
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	function PlayAddressT_YT(address, resent)
		address = m_simpleTV.Common.fromPercentEncoding(address)
		address = stringFromHex(address)
		address = urls_encode(address)
		m_simpleTV.Control.PlayAddressT({address = address, insertInRecent = resent})
	end
	function SavePlst_YT()
		if m_simpleTV.User.YT.Plst and m_simpleTV.User.YT.plstHeader then
			local t = m_simpleTV.User.YT.Plst
			local header = m_simpleTV.User.YT.plstHeader
			local adr, name, logo
			local m3ustr = '#EXTM3U $ExtFilter="YouTube" $BorpasFileFormat="1"\n'
				for i = 1, #t do
					name = t[i].Name
					logo = t[i].Address:match('v=([^&]*)') or ''
					adr = t[i].Address:gsub('&is%a+=%a+', '')
					m3ustr = m3ustr
							.. '#EXTINF:-1'
							.. ' group-title="' .. header .. '"'
							.. ' tvg-logo="https://i.ytimg.com/vi/' .. logo .. '/hqdefault.jpg"'
							.. ','
							.. name
							.. '\n' .. adr .. '\n'
				end
			if m_simpleTV.User.YT.PlstsCh.chTitle then
				header = header .. ' [' .. m_simpleTV.User.YT.Lng.channel
								.. ' - ' .. m_simpleTV.User.YT.PlstsCh.chTitle .. '] '
			end
			header = m_simpleTV.Common.UTF8ToMultiByte(header)
			header = header:gsub('%c', '')
			header = header:gsub('[\/"*:<>|?]+', ' ')
			header = header:gsub('%s+', ' ')
			header = header:gsub('^%s*(.-)%s*$', '%1')
			local fileEnd = ' (youtube ' .. os.date('%d.%m.%y') .. ').m3u8'
			local folder = m_simpleTV.Common.GetMainPath(1) .. m_simpleTV.Common.UTF8ToMultiByte(m_simpleTV.User.YT.Lng.savePlstFolder) .. '/'
			lfs.mkdir(folder)
			local folderYT = folder .. 'YouTube/'
			lfs.mkdir(folderYT)
			local filePath = folderYT .. header .. fileEnd
			local fhandle = io.open(filePath, 'w+')
			if fhandle then
				fhandle:write(m3ustr)
				fhandle:close()
				ShowInfo(
							m_simpleTV.User.YT.Lng.savePlst_1 .. '\n'
							.. m_simpleTV.Common.multiByteToUTF8(header .. fileEnd) .. '\n'
							.. m_simpleTV.User.YT.Lng.savePlst_2 .. '\n'
							.. m_simpleTV.Common.multiByteToUTF8(folderYT)
						)
			else
				ShowInfo(m_simpleTV.User.YT.Lng.savePlst_3)
			end
		end
	end
	function Qlty_YT()
		local t = m_simpleTV.User.YT.QltyTab
			if not t or #t < 2 then
				m_simpleTV.Control.ExecuteAction(37)
			 return
			end
		if m_simpleTV.User.paramScriptForSkin_buttonInfo then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonInfo, ButtonScript = 'Qlty_YT()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = 'ℹ️'}
		end
		t.ExtParams = {FilterType = 2}
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if not m_simpleTV.User.YT.isVideo then
			if m_simpleTV.User.paramScriptForSkin_buttonSave then
				t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonSave}
			else
				t.ExtButton0 = {ButtonEnable = true, ButtonName = '💾'}
			end
		else
			if m_simpleTV.User.paramScriptForSkin_buttonSearch then
				t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonSearch}
			else
				t.ExtButton0 = {ButtonEnable = true, ButtonName = '🔎'}
			end
		end
		m_simpleTV.Control.ExecuteAction(37)
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ ' .. m_simpleTV.User.YT.Lng.qlty
														, m_simpleTV.User.YT.QltyIndex - 1, t, 5000, 1 + 4 + 2)
		if m_simpleTV.Control.GetState() == 0 and ret == 0 then
			m_simpleTV.Control.ExecuteAction(108)
		end
		if ret == 1 then
			if t[id].qltyLive then
				m_simpleTV.Config.SetValue('YT_qlty_live', t[id].qltyLive)
				m_simpleTV.User.YT.qlty_live = t[id].qltyLive
			else
				if t[id].qlty > 300 then
					m_simpleTV.Config.SetValue('YT_qlty', t[id].qlty)
					m_simpleTV.User.YT.qlty0 = t[id].qlty
				end
				if t[id].qlty < 100 then
					local visual = tostring(m_simpleTV.Config.GetValue('vlc/audio/visual/module', 'simpleTVConfig') or '')
					if visual == 'none'
						or visual == ''
					then
						SetBackground(m_simpleTV.User.YT.pic or m_simpleTV.User.YT.logoPicFromDisk)
					else
						SetBackground()
					end
				end
				m_simpleTV.User.YT.qlty = t[id].qlty
			end
			if (t[id].qlty and t[id].qlty > 100) or t[id].qltyLive then
				SetBackground()
			end
			m_simpleTV.User.YT.QltyIndex = id
			if isInfoPanel == false then
				ShowMsg(t[id].Name, nil, true)
			end
			local retAdr = t[id].Address:gsub('$OPT:start%-time=%d+', '')
			retAdr = StreamCheck(t, id)
			m_simpleTV.Control.SetNewAddressT({address = retAdr, position = m_simpleTV.Control.GetPosition()})
			if m_simpleTV.Control.GetState() == 0 then
				m_simpleTV.Control.Restart(false)
			end
		end
		if ret == 2
			and not m_simpleTV.User.YT.isVideo
		then
			SavePlst_YT()
		elseif ret == 2 and m_simpleTV.User.YT.isVideo and id then
			m_simpleTV.Control.ExecuteAction(105)
		end
		if ret == 3
		then
			ShowInfo()
		end
	end
	function PlstsCh_YT()
			if m_simpleTV.Control.Reason == 'Stopped'
				or m_simpleTV.Control.Reason == 'EndReached'
			then
				m_simpleTV.Control.ExecuteAction(63)
			 return
			end
		local tab = m_simpleTV.User.YT.PlstsChTab
			if not tab then return end
		local num = m_simpleTV.User.YT.PlstsCh.Num
		local index = 0
			for k, v in ipairs(tab) do
				if tonumber(num) == tonumber(v.Name:match('^(%d+)')) then
					index = k
				end
			end
		tab.ExtParams = {FilterType = 2}
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			tab.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('📋 ' .. m_simpleTV.User.YT.ChTitle, index - 1, tab, 30000, 1 + 4 + 2 + 128)
		if not id then
			m_simpleTV.Control.ExecuteAction(37)
			if m_simpleTV.Control.GetState() == 0 then
				m_simpleTV.Control.RestoreBackground()
			end
		end
			if ret == 1 then
				m_simpleTV.User.YT.PlstsCh.Refresh = true
				m_simpleTV.User.YT.PlstsCh.Num = tab[id].Name:match('^(%d+)') or tab[1].Name
				m_simpleTV.User.YT.PlstsCh.Header = tab[id].Name:match('^%d+%. (.+)') or tab[1].Name
				m_simpleTV.Control.SetNewAddressT({address = tab[id].Address})
			 return
			end
			if ret == 2 then
				PrevPlstsCh_YT()
			 return
			end
			if ret == 3 then
				NextPlstsCh_YT()
			 return
			end
	end
	function NextPlstsCh_YT()
		m_simpleTV.User.YT.PlstsCh.Refresh = true
		local tab = table_reversa(m_simpleTV.User.YT.PlstsCh.Urls)
		if #tab == 0 then
			tab[1] = m_simpleTV.User.YT.PlstsCh.FirstUrl
		end
		m_simpleTV.Control.ChangeAddress = 'No'
		m_simpleTV.Control.CurrentAddress = tab[1] .. '&isRestart=true'
		dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
	end
	function PrevPlstsCh_YT()
		m_simpleTV.User.YT.PlstsCh.Refresh = false
		local tab = m_simpleTV.User.YT.PlstsCh.Urls
		if #tab > 1 then
			tab[#tab] = nil
			tab[#tab] = nil
		end
		if #tab == 0 then
			m_simpleTV.Control.CurrentAddress = m_simpleTV.User.YT.PlstsCh.MainUrl
		else
			m_simpleTV.Control.CurrentAddress = tab[#tab]
		end
		m_simpleTV.User.YT.PlstsCh.Urls = tab
		m_simpleTV.Control.ChangeAddress = 'No'
		dofile(m_simpleTV.MainScriptDir .. 'user/video/YT.lua')
	end
	function MarkWatched_YT(sessionMarkWatch)
		m_simpleTV.Http.Close(sessionMarkWatch)
	end
	function OnMultiAddressOk_YT(Object, id)
		if id == 0 then
			OnMultiAddressCancel_YT(Object)
		else
			m_simpleTV.User.YT.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_YT(Object)
		if m_simpleTV.User.YT.DelayedAddress then
			if m_simpleTV.Control.GetState() == 0 then
				m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.YT.DelayedAddress})
				if m_simpleTV.User.YT.qlty < 100 then
					local visual = tostring(m_simpleTV.Config.GetValue('vlc/audio/visual/module', 'simpleTVConfig') or '')
					if visual == 'none'
						or visual == ''
					then
						SetBackground(m_simpleTV.User.YT.pic or m_simpleTV.User.YT.logoPicFromDisk)
					else
						SetBackground()
					end
				end
			end
			m_simpleTV.User.YT.DelayedAddress = nil
		end
		m_simpleTV.Control.ExecuteAction(36, 0)
	end
		if not m_simpleTV.User.YT.isAuth
			and (inAdr:match('list=WL')
			or inAdr:match('list=LL')
			or inAdr:match('list=LM')
			or (inAdr:match('/feed/')
				and not inAdr:match('/feed/storefront')
				and not inAdr:match('/feed/trending')))
		then
			local err = '⚠️ ' .. m_simpleTV.User.YT.Lng.noCookies
			StopOnErr(100, err)
		 return
		end
	if inAdr:match('isPlstsCh=true') then
		m_simpleTV.User.YT.isPlstsCh = true
	end
	if inAdr:match('/watch_videos')
	then
		inAdr = GetUrlWatchVideos(inAdr)
			if not inAdr then
				StopOnErr(0.8)
			 return
			end
		m_simpleTV.Http.Close(session)
		PlayAddressT_YT(inAdr)
	 return
	end
	if inAdr:match('^%-') then
		if m_simpleTV.Control.MainMode == 0 then
			if not inAdr:match('^%-related=') then
				m_simpleTV.Control.ChangeChannelLogo('https://s.ytimg.com/yts/img/reporthistory/land-img-vfl_eF5BA.png', m_simpleTV.Control.ChannelID)
			else
				m_simpleTV.Control.ExecuteAction(37)
			end
		end
		local t, types, header = Search(inAdr)
		m_simpleTV.Http.Close(session)
			if not t or #t == 0 then
				StopOnErr(5.1, m_simpleTV.User.YT.Lng.notFound)
			 return
			end
		local title
		if types == 'related' then
			title = m_simpleTV.User.YT.title
			title = title_clean(title)
		else
			title = inAdr:gsub('^[%-%+%s]+(.-)%s*$', '%1')
		end
		title = m_simpleTV.User.YT.Lng.search .. ' YouTube (' .. header .. '): ' .. title
		m_simpleTV.Control.SetTitle(title)
		local FilterType, AutoNumberFormat
		if #t > 5 then
			FilterType = 1
			AutoNumberFormat = '%1. %2'
		else
			FilterType = 2
			AutoNumberFormat = ''
		end
		t.ExtParams = {FilterType = FilterType, AutoNumberFormat = AutoNumberFormat}
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy = 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('🔎 ' .. title, 0, t, 30000, 1 + 4 + 8 + 2)
		m_simpleTV.Control.ExecuteAction(37)
			if not id or ret == 3 then
				m_simpleTV.Control.ExecuteAction(11)
			 return
			end
		t = t[id].Address .. '&isSearch=true&isLogo=false&isButton=true'
		PlayAddressT_YT(t)
	 return
	end
	if inAdr:match('isPlst=') then
		m_simpleTV.User.YT.isVideo = false
	end
	if inAdr:match('/user/[^/]+/videos')
		or inAdr:match('/channel/[^/]+/videos')
		or inAdr:match('/c/[^/]+/videos')
		or inAdr:match('index=')
		or inAdr:match('/feed/')
		or inAdr:match('/hashtag/')
		or inAdr:match('youtube%.com$')
		or ((inAdr:match('list=RD')
			or inAdr:match('list=TL'))
			and not inAdr:match('/embed'))
		or inAdr:match('list=WL')
		or inAdr:match('list=OL')
		or inAdr:match('list=LM')
		or inAdr:match('list=LL')
		or inAdr:match('youtube%.com/[^/]+/videos')
	then
		Plst(inAdr)
	elseif inAdr:match('/user/')
		or inAdr:match('/channel/')
		or inAdr:match('/c/')
		or inAdr:match('/youtubei/')
		or inAdr:match('youtube%.com/%w+$')
		or inAdr:match('youtube%.com/[^/]+/playlists')
		or inAdr:match('/live$')
		or inAdr:match('/embed/live_stream')
	then
		PlstsCh(inAdr)
	elseif inAdr:match('list=') then
		PlstApi(inAdr)
	else
		Video()
	end
