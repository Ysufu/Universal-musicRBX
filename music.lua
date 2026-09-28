--[[
    ═══════════════════════════════════════════════════════════════
    🎵 YUSZX MUSIC — Mobile Spotify Style
    ═══════════════════════════════════════════════════════════════
    Layout mini player (fix di bawah layar):
    ┌─────────────────────────────────────┐
    │ ▬▬▬▬▬▬▬▬▬▬▬░░░░░░░░░░░░░░░░░░░░░░░ │ ← progress tipis
    │ ┌──┐ Title                         │
    │ │♪ │ Artist          ⏮ ▶ ⏭  ▲     │ ← kontrol kanan
    │ └──┘                                │
    └─────────────────────────────────────┘
    ═══════════════════════════════════════════════════════════════
]]

-- ============================================
-- UNIVERSAL HELPER
-- ============================================
local function getSafeParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    local plr = game:GetService("Players").LocalPlayer
    return plr:FindFirstChild("PlayerGui") or plr
end

local function getSafeSoundParent()
    local candidates = {}
    pcall(function() table.insert(candidates, game:GetService("SoundService")) end)
    table.insert(candidates, workspace)
    for _, p in ipairs(candidates) do
        if p then
            local test = Instance.new("Sound")
            local ok = pcall(function() test.Parent = p end)
            if ok and test.Parent then
                test:Destroy()
                return p
            end
            test:Destroy()
        end
    end
    return workspace
end

local uiParent = getSafeParent()
local soundParent = getSafeSoundParent()

-- ============================================
-- CONFIG
-- ============================================
local CONFIG_FILE = "YuszxMusic_config.json"
local DEFAULT_CONFIG = { Volume = 0.5, Loop = false, Shuffle = false, Minimized = false }
local Config = {}
for k, v in pairs(DEFAULT_CONFIG) do Config[k] = v end

function Config.load()
    if not readfile or not isfile then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local d = game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(d) do Config[k] = v end
        end
    end)
end
function Config.save()
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(Config))
    end)
end
function Config.get(k, d) return Config[k] ~= nil and Config[k] or d end
function Config.set(k, v) Config[k] = v; Config.save() end
Config.load()

-- ============================================
-- COLORS (Spotify)
-- ============================================
local C = {
    BG = Color3.fromRGB(18, 18, 18),
    BG_LIGHT = Color3.fromRGB(36, 36, 36),
    CARD = Color3.fromRGB(40, 40, 40),
    GREEN = Color3.fromRGB(29, 185, 84),
    WHITE = Color3.fromRGB(255, 255, 255),
    GRAY = Color3.fromRGB(179, 179, 179),
    DIM = Color3.fromRGB(120, 120, 120),
    TRACK = Color3.fromRGB(85, 85, 85),
}

-- ============================================
-- PLAYLIST
-- ============================================
  local PLAYLIST = {
    -- ============================================
    -- 🎵 POP / HITS (150+)
    -- ============================================
    {id = "2071829884", title = "God Is a Woman", artist = "Ariana Grande"},
    {id = "8026236684", title = "SAD GIRLZ LUV MONEY", artist = "Amaarae"},
    {id = "5321298199", title = "Daisy", artist = "Ashnikko"},
    {id = "225150067", title = "Suga Suga", artist = "Baby Bash"},
    {id = "614018503", title = "Baby Shark", artist = "Pinkfong"},
    {id = "3017157406", title = "Bad Guy", artist = "Billie Eilish"},
    {id = "7079888477", title = "NDA", artist = "Billie Eilish"},
    {id = "5622020090", title = "My Future", artist = "Billie Eilish"},
    {id = "1321038120", title = "Ocean Eyes", artist = "Billie Eilish"},
    {id = "1357813567", title = "So Hot", artist = "BLACKPINK"},
    {id = "5512350519", title = "Rasputin", artist = "Boney M"},
    {id = "6844912719", title = "Butter", artist = "BTS"},
    {id = "1894066752", title = "Fake Love", artist = "BTS"},
    {id = "5253604010", title = "Oh No", artist = "Capone"},
    {id = "748726200", title = "No Limit", artist = "Casi"},
    {id = "5937000690", title = "Chikatto Chika Chika", artist = "Anime"},
    {id = "2106186490", title = "Solo", artist = "Clean Bandit"},
    {id = "6070263388", title = "Gangsta's Paradise", artist = "Coolio"},
    {id = "166562385", title = "Sandstorm", artist = "Darude"},
    {id = "521116871", title = "Say So", artist = "Doja Cat"},
    {id = "1665926924", title = "God's Plan", artist = "Drake"},
    {id = "143854033", title = "Headlines", artist = "Drake"},
    {id = "302588405", title = "Hotline Bling", artist = "Drake"},
    {id = "394260844", title = "One Dance", artist = "Drake"},
    {id = "530322917", title = "Sneakin'", artist = "Drake"},
    {id = "397693837", title = "Be The One", artist = "Dua Lipa"},
    {id = "505241403", title = "Blow Your Mind", artist = "Dua Lipa"},
    {id = "410212866", title = "Hotter Than Hell", artist = "Dua Lipa"},
    {id = "1313745214", title = "IDGAF", artist = "Dua Lipa"},
    {id = "6606223785", title = "Levitating", artist = "Dua Lipa"},
    {id = "907628353", title = "New Rules", artist = "Dua Lipa"},
    {id = "6257964687", title = "We're Good", artist = "Dua Lipa"},
    {id = "7202579511", title = "Bad Habits", artist = "Ed Sheeran"},
    {id = "5808184278", title = "I See Red", artist = "Everybody Loves An Outlaw"},
    {id = "210783060", title = "Trap Queen", artist = "Fetty Wap"},
    {id = "1725273277", title = "Chanel", artist = "Frank Ocean"},
    {id = "189105508", title = "Let It Go", artist = "Frozen"},
    {id = "1837015626", title = "Tokyo Drift", artist = "Fumitake Igarashi"},
    {id = "6432181830", title = "Heat Waves", artist = "Glass Animals"},
    {id = "249672730", title = "On My Way", artist = "Illijah"},
    {id = "146237847", title = "Trumpets", artist = "Jason Derulo"},
    {id = "168208965", title = "Whatcha Say", artist = "Jason Derulo"},
    {id = "8036100972", title = "Lucid Dreams", artist = "Juice WRLD"},
    {id = "4591688095", title = "Yummy", artist = "Justin Bieber"},
    {id = "333659569", title = "Mercy", artist = "Kanye West"},
    {id = "136209425", title = "Stronger", artist = "Kanye West"},
    {id = "321199908", title = "Milkshake", artist = "Kelis"},
    {id = "130964099", title = "Applause", artist = "Lady Gaga"},
    {id = "7253841629", title = "Industry Baby", artist = "Lil Nas X"},
    {id = "7551431783", title = "Money", artist = "LISA"},
    {id = "673605737", title = "Despacito", artist = "Luis Fonsi"},
    {id = "413514503", title = "Alone", artist = "Marshmello"},
    {id = "291895335", title = "Moves Like Jagger", artist = "Maroon 5"},
    {id = "131396974", title = "Payphone", artist = "Maroon 5"},
    {id = "6422642623", title = "Astronaut In The Ocean", artist = "Masked Wolf"},
    {id = "4883181281", title = "Smooth Criminal", artist = "Michael Jackson"},
    {id = "6937354391", title = "Brutal", artist = "Olivia Rodrigo"},
    {id = "2733151293", title = "Sunflower", artist = "Post Malone"},
    {id = "4581203569", title = "Never Gonna Give You Up", artist = "Rick Astley"},
    {id = "142533681", title = "Diamonds", artist = "Rihanna"},
    {id = "6901063458", title = "SOS", artist = "Rihanna"},
    {id = "395794636", title = "Work", artist = "Rihanna"},
    {id = "1843436418", title = "Running", artist = "Tom Hillock"},
    {id = "63735955004", title = "Jenny", artist = "Studio Killers"},
    {id = "130794482", title = "I Knew You Were Trouble", artist = "Taylor Swift"},
    {id = "6463211475", title = "Jalebi Baby", artist = "Tesher"},
    {id = "138134680", title = "Let's Get It Started", artist = "Black Eyed Peas"},
    {id = "6828176320", title = "Paint It Black", artist = "Rolling Stones"},

    -- ============================================
    -- 🎼 CLASSICAL (40+)
    -- ============================================
    {id = "1838457617", title = "Claire De Lune", artist = "Claude Debussy"},
    {id = "1846627783", title = "Nutcracker Suite", artist = "Tchaikovsky"},
    {id = "450051032", title = "Fur Elise", artist = "Beethoven"},
    {id = "445023353", title = "Moonlight Sonata", artist = "Beethoven"},
    {id = "564238335", title = "Toccata & Fugue in D Minor", artist = "Bach"},
    {id = "1846088038", title = "Morning Mood", artist = "Peer Gynt"},
    {id = "9045766074", title = "The Four Seasons - Spring", artist = "Vivaldi"},
    {id = "9045765634", title = "Nocturne in E-Flat Major", artist = "Chopin"},
    {id = "1846051682", title = "Clair De Lune (Alt)", artist = "Claude Debussy"},
    {id = "9045765295", title = "The Blue Danube", artist = "Strauss"},
    {id = "9045766377", title = "Gymnopedie No. 1", artist = "Satie"},
    {id = "1848028342", title = "Nocturne Opus 9 C", artist = "Chopin"},
    {id = "1837474061", title = "Gymnopedie No. 1 (Alt)", artist = "Satie"},
    {id = "1847569222", title = "Land Of Hope And Glory", artist = "Elgar"},
    {id = "135308045", title = "Sad Violin", artist = "Classical"},
    {id = "1847157122", title = "Symphony No.9 New World", artist = "Dvorak"},
    {id = "1846627271", title = "Hallelujah (Messiah)", artist = "Handel"},
    {id = "926493242", title = "Soft Jazz", artist = "Jazz"},

    -- ============================================
    -- 🎮 PHONK (50+)
    -- ============================================
    {id = "17422173467", title = "AB4T", artist = "Phonk"},
    {id = "89824897586105", title = "Above Phonk", artist = "Phonk"},
    {id = "17422074849", title = "Alanwaad", artist = "Phonk"},
    {id = "15689451063", title = "Metamorphosis", artist = "Phonk"},
    {id = "14145627474", title = "Back & Front", artist = "Phonk"},
    {id = "125498129824026", title = "Brazil Fiesta", artist = "Phonk"},
    {id = "16190760005", title = "Cowbell God", artist = "Phonk"},
    {id = "14145621151", title = "Emotional Damage", artist = "Phonk"},
    {id = "93203762220779", title = "End the Soft", artist = "Phonk"},
    {id = "101326109963284", title = "F-Phonk", artist = "Phonk"},
    {id = "18841887539", title = "Gabbermix", artist = "Phonk"},
    {id = "8185857772", title = "Heptraxous", artist = "Phonk"},
    {id = "16190784875", title = "Infinite", artist = "Phonk"},
    {id = "15689453529", title = "Invade Groom", artist = "Phonk"},
    {id = "14145623221", title = "No Lights", artist = "Phonk"},
    {id = "14145625743", title = "Phonk't Out", artist = "Phonk"},
    {id = "96461852889782", title = "Pure Phonk Violence", artist = "Phonk"},
    {id = "16190783774", title = "Redemption", artist = "Phonk"},
    {id = "15689443663", title = "Sinistra", artist = "Phonk"},

    -- ============================================
    -- 🎧 EDM / ELECTRONIC (80+)
    -- ============================================
    {id = "5410086218", title = "Crab Rave", artist = "Noisestorm"},
    {id = "5410085763", title = "PLAY", artist = "Tokyo Machine"},
    {id = "7029024726", title = "Bloom", artist = "Throttle"},
    {id = "7023635858", title = "Vex", artist = "Bensley"},
    {id = "7024220835", title = "Easter Egg", artist = "Nitro Fun"},
    {id = "5410081542", title = "Taking Me Higher", artist = "Rootkit"},
    {id = "5410084538", title = "The Storm", artist = "Notaker"},
    {id = "9046476113", title = "Cyber Space", artist = "Audio Library"},
    {id = "1836894438", title = "The Spectre", artist = "Alan Walker"},
    {id = "1839246711", title = "Jumpstyle", artist = "EDM"},

    -- ============================================
    -- 🎌 ANIME / GAME OST (60+)
    -- ============================================
    {id = "4973416812", title = "Attack on Titan Theme", artist = "Anime"},
    {id = "733982763", title = "Shinzou Wo Sasageyo", artist = "AoT"},
    {id = "5682636501", title = "Gurenge", artist = "Demon Slayer"},
    {id = "3457906535", title = "Giorno's Theme", artist = "JoJo"},
    {id = "158779833", title = "Death Note Theme", artist = "Anime"},
    {id = "4801419764", title = "Memory Lane", artist = "AcesToAces"},
    {id = "493647101", title = "Fight", artist = "Aests"},
    {id = "4480231706", title = "Miku", artist = "Anamanaguchi"},

    -- ============================================
    -- 😂 MEME / FUN (100+)
    -- ============================================
    {id = "1259050178", title = "A Roblox Rap", artist = "Roblox"},
    {id = "3180460921", title = "Old Town Road OOFED", artist = "Meme"},
    {id = "256575709", title = "JUST DO IT!", artist = "Shia LaBeouf"},
    {id = "1237557124", title = "Roblox OOF Sound", artist = "Roblox"},
    {id = "142376088", title = "Raining Tacos", artist = "Parry Gripp"},
    {id = "9120386436", title = "Ding / Success", artist = "SFX"},
    {id = "9048375035", title = "All Dropping 8-Bit", artist = "SFX"},
    {id = "1842976958", title = "Arcade Weekend", artist = "Audio"},
    {id = "1841905171", title = "Collider", artist = "Audio"},
    {id = "1837848642", title = "Crystal Clear", artist = "Audio"},
    {id = "7363412529", title = "You've Been Rick Rolled", artist = "Meme"},
    {id = "5476307813", title = "Alarm", artist = "SFX"},
    {id = "1837258874", title = "La Cucaracha", artist = "Traditional"},
    {id = "1626996526", title = "Windows XP Theme", artist = "Microsoft"},
    {id = "170041353", title = "I am in My Mom Car", artist = "Meme"},
    {id = "4769589095", title = "Can You Hear Me", artist = "Meme"},
    {id = "9106904975", title = "Better Call Saul Theme", artist = "TV"},
    {id = "9117767488", title = "Police Radio", artist = "SFX"},
    {id = "81305726611791", title = "Jackpot Kill Sound", artist = "SFX"},
    {id = "140273522273411", title = "Perfect Dodge Kill", artist = "SFX"},
    {id = "103976786559083", title = "Grab SFX Kill", artist = "SFX"},
    {id = "3732358952", title = "Villager Death", artist = "Minecraft"},
    {id = "4362818605", title = "Bruh Sound", artist = "Meme"},
    {id = "8381480398", title = "A Shameful Display", artist = "Meme"},
    {id = "7750368290", title = "Bonk", artist = "TF2"},
    {id = "7361042352", title = "Mario Death Sound", artist = "Mario"},
    {id = "678089961", title = "MLG Airhorns", artist = "Meme"},
    {id = "6308606116", title = "Vine Boom", artist = "Meme"},
    {id = "102942819597181", title = "Get the Camera", artist = "Meme"},
    {id = "135964942694135", title = "Luffy Laugh", artist = "One Piece"},
    {id = "139056779819258", title = "Ara Ara", artist = "Anime"},
    {id = "138343024353929", title = "Whitebeard Laugh", artist = "One Piece"},
    {id = "182755256", title = "Mario Powerup", artist = "Mario"},
    {id = "4634837608", title = "Tetris Theme", artist = "Tetris"},
    {id = "169736440", title = "Mountain Nature", artist = "Ambient"},
    {id = "7262900392", title = "Town Ambient", artist = "Ambient"},
    {id = "728506251", title = "Forest Sounds", artist = "Ambient"},
    {id = "5595380425", title = "Eerie Horror", artist = "Ambient"},
    {id = "5743541225", title = "Red Alert Alarm", artist = "SFX"},
    {id = "8553715724", title = "Take This", artist = "Meme"},
    {id = "1352824542", title = "Noob", artist = "Meme"},
    {id = "8361667514", title = "COD Zombie", artist = "CoD"},
    {id = "506001681", title = "Die Die Die", artist = "Meme"},
    {id = "115939761210231", title = "Don't Steal My Brainrot", artist = "Meme"},
    {id = "84218503563919", title = "Brainrot Anthem", artist = "Meme"},
    {id = "70455732863262", title = "Ballerina Cappucinna", artist = "Brainrot"},
    {id = "126267754440216", title = "Backrooms Monster", artist = "Horror"},
    {id = "139668725303708", title = "Metal Pipe Falling", artist = "Meme"},
    {id = "117492777052206", title = "What Up Son", artist = "Meme"},
    {id = "6073491164", title = "Android Notification", artist = "SFX"},
    {id = "7111183238", title = "What The Dog Doin", artist = "Meme"},
    {id = "366983090", title = "LOUD AUDIO", artist = "SFX"},
    {id = "93601206924895", title = "Level Up", artist = "SFX"},
    {id = "6296179658", title = "Victory Fanfare", artist = "SFX"},
    {id = "6093842800", title = "Defeat Sad Trombone", artist = "SFX"},
    {id = "131961423434755", title = "Coin Collect", artist = "Mario"},
    {id = "119749112819204", title = "Minecraft Hurt", artist = "Minecraft"},
    {id = "102908316388959", title = "Creeper Hiss", artist = "Minecraft"},
    {id = "126639170779611", title = "Among Us Kill", artist = "Among Us"},
    {id = "130202454187540", title = "Among Us Meeting", artist = "Among Us"},
    {id = "131050907920768", title = "FNAF Jumpscare", artist = "FNAF"},
    {id = "138244846213140", title = "Sus Amogus", artist = "Meme"},

    -- ============================================
    -- 🎹 AMBIENT / CHILL (200+)
    -- ============================================
    {id = "1838603000", title = "1812 Remastered", artist = "Classical"},
    {id = "1842660840", title = "Cave", artist = "Ambient"},
    {id = "9045941477", title = "Mission Danger", artist = "Audio Library"},
    {id = "9047725736", title = "Two Times Two", artist = "Audio Library"},
    {id = "71237833581498", title = "Cold Coffee", artist = "Lo-fi"},
    {id = "9046435309", title = "The Still, Sad Music", artist = "Audio Library"},
    {id = "1844244712", title = "Happy Birthday Carousel", artist = "Audio Library"},
    {id = "1837099568", title = "Ethereal Hope C", artist = "Audio Library"},
    {id = "1837779395", title = "Stealth Warrior", artist = "Audio Library"},
    {id = "1837301393", title = "Epic Race", artist = "Audio Library"},
    {id = "1836393197", title = "Feels Right", artist = "Audio Library"},
    {id = "9046601136", title = "Watching the Garden Grow", artist = "Audio Library"},
    {id = "9042632936", title = "Fuel Fury", artist = "Audio Library"},
    {id = "1836098504", title = "Tender Chillstep", artist = "Audio Library"},
    {id = "1842627030", title = "Funky Beats", artist = "Audio Library"},
    {id = "1845919739", title = "Bandung", artist = "Audio Library"},
    {id = "9043360237", title = "Metallic Drone 03", artist = "Ambient"},
    {id = "1842612641", title = "Boombox Jazz", artist = "Audio Library"},
    {id = "1837039239", title = "Dance, Dance, Dance", artist = "Audio Library"},
    {id = "9044582869", title = "Fight To the Last Ship", artist = "Audio Library"},
    {id = "9038367768", title = "Funky Disco Beats", artist = "Audio Library"},
    {id = "1838405655", title = "Action Reaction", artist = "Audio Library"},
    {id = "7029092469", title = "Love Is", artist = "Vintage & Morelli"},
    {id = "1838214973", title = "Beach Bar", artist = "Audio Library"},
    {id = "1840201434", title = "Crystal Forest", artist = "Audio Library"},
    {id = "1845703476", title = "Holiday Fun", artist = "Audio Library"},
    {id = "129775776987523", title = "Lo-fi Ambient", artist = "Lo-fi"},
    {id = "1839805889", title = "Enchanting Choir", artist = "Ambient"},
    {id = "1848227837", title = "Lucky Synth", artist = "Audio Library"},
    {id = "115997397744543", title = "Meat n' Greet", artist = "Audio Library"},
    {id = "1837584804", title = "Race (60)", artist = "Audio Library"},
    {id = "1842908030", title = "Road To War", artist = "Audio Library"},
    {id = "1839817591", title = "Animation Opening", artist = "Audio Library"},
    {id = "1838825185", title = "Happiness", artist = "Audio Library"},
    {id = "1836657065", title = "Wind", artist = "Ambient"},
    {id = "17422156627", title = "HR - WASSA", artist = "Audio Library"},
    {id = "1837315002", title = "Street Balls of Fire", artist = "Audio Library"},
    {id = "1848365527", title = "Airsong", artist = "Audio Library"},
    {id = "122138664583233", title = "Sunset", artist = "Lo-fi"},
    {id = "118356025252463", title = "Peaceful Harvest Moon", artist = "Ambient"},
    {id = "1845205138", title = "Forest Chase", artist = "Audio Library"},
    {id = "1836289689", title = "Silly Chase", artist = "Audio Library"},
    {id = "1837070127", title = "Prima Bossa Nova", artist = "Audio Library"},
    {id = "1841722030", title = "Acoustic Traveller", artist = "Audio Library"},
    {id = "1843943122", title = "Intensity", artist = "Audio Library"},
    {id = "102518604969857", title = "Poke Battle Hardstyle", artist = "Audio Library"},
    {id = "9043053143", title = "Playful Panda C", artist = "Audio Library"},
    {id = "1845252747", title = "Happy", artist = "Audio Library"},
    {id = "1846999567", title = "Creepy Night", artist = "Audio Library"},
    {id = "91764593646703", title = "KPop Demon Hunters", artist = "K-Pop"},
    {id = "1840684377", title = "A Short Intermission", artist = "Audio Library"},
    {id = "9047104571", title = "Home Town Easy", artist = "Audio Library"},
    {id = "1839444520", title = "Cat Chase", artist = "Audio Library"},
    {id = "1840434123", title = "Hotel Deluxe", artist = "Audio Library"},
    {id = "1839624545", title = "Soft And Mellow", artist = "Audio Library"},
    {id = "1838667764", title = "Christmas Tree", artist = "Audio Library"},
    {id = "1836842889", title = "Solar Flares", artist = "Audio Library"},
    {id = "1847418280", title = "Baby Rap A", artist = "Audio Library"},
    {id = "94378181487716", title = "Free Will Funk", artist = "Audio Library"},
    {id = "9047104650", title = "Decompression", artist = "Audio Library"},
    {id = "1842597135", title = "Space Race", artist = "Audio Library"},
    {id = "1839029408", title = "Funny Days", artist = "Audio Library"},
    {id = "104207837699519", title = "Tabola Bale", artist = "Audio Library"},
    {id = "9047134387", title = "Tropical Breeze A", artist = "Audio Library"},
    {id = "118507373399694", title = "Melodia de Verão", artist = "TikTok"},
    {id = "1838667039", title = "Ode To Christmas", artist = "Audio Library"},
    {id = "9047105584", title = "On The Verge", artist = "Audio Library"},
    {id = "9038367978", title = "Funky Disco Beats 15s", artist = "Audio Library"},
    {id = "9044539308", title = "Fashion Lobby", artist = "Audio Library"},
    {id = "1846631912", title = "Bright Background", artist = "Audio Library"},
    {id = "9045311328", title = "Sneaking Around", artist = "Audio Library"},
    {id = "1837879143", title = "Paradise Falls Alt2", artist = "Audio Library"},
    {id = "78972962223923", title = "Autumn Leaves", artist = "Jazz"},
    {id = "116197983114890", title = "Billie Jean", artist = "Michael Jackson"},
    {id = "9047104752", title = "Monday Morning", artist = "Audio Library"},
    {id = "1845149698", title = "Seek & Destroy", artist = "Audio Library"},
    {id = "1837138942", title = "Le Roi qui s'ennuyait", artist = "Audio Library"},
    {id = "140009716850576", title = "ERROR 264", artist = "SFX"},
    {id = "1846911135", title = "Really Fast", artist = "Audio Library"},
    {id = "9043887091", title = "Lo-fi Chill A", artist = "Lo-fi"},
    {id = "16190782181", title = "HR - EEYUH!", artist = "Audio Library"},
    {id = "1845497774", title = "Into The Forest", artist = "Audio Library"},
    {id = "1843404009", title = "Happy Song", artist = "Audio Library"},
    {id = "1837768517", title = "Bossa Me", artist = "Audio Library"},
    {id = "120102995443063", title = "Stray", artist = "Audio Library"},
    {id = "1846458016", title = "No More", artist = "Audio Library"},
    {id = "1838674668", title = "Cartoon Scene", artist = "Audio Library"},
    {id = "1845756489", title = "Town Talk", artist = "Audio Library"},
    {id = "91785810573969", title = "Your Old Life", artist = "Audio Library"},
    {id = "1841106534", title = "Window Shopping", artist = "Audio Library"},
    {id = "1841476350", title = "Happy-Go-Lively", artist = "Audio Library"},
    {id = "1840384241", title = "The Nice Things", artist = "Audio Library"},
    {id = "89180400948567", title = "FUSION", artist = "Audio Library"},
    {id = "1838028467", title = "VIP Me", artist = "Audio Library"},
    {id = "9046865270", title = "Glowing Light", artist = "Audio Library"},
    {id = "1836822226", title = "Natural Innovation", artist = "Audio Library"},
    {id = "1838998447", title = "Western Spaghetti", artist = "Audio Library"},
    {id = "9046862941", title = "Sunset Chill", artist = "Lo-fi"},
    {id = "1842616211", title = "Step To My Dub", artist = "Audio Library"},
    {id = "1840434670", title = "Funky (A)", artist = "Audio Library"},
    {id = "1839638511", title = "Island Beach", artist = "Audio Library"},
    {id = "9042578129", title = "Fun In Paradise", artist = "Audio Library"},
    {id = "1841998846", title = "Lobby Soirée", artist = "Audio Library"},
    {id = "75485931767123", title = "Alone", artist = "Audio Library"},
    {id = "9047105702", title = "Light Dreamer", artist = "Audio Library"},
    {id = "1839755255", title = "Cute Story", artist = "Audio Library"},
    {id = "1839023851", title = "Tense Night", artist = "Audio Library"},
    {id = "9039953638", title = "Piano Style", artist = "Piano"},
    {id = "99445078556609", title = "Hope", artist = "Ambient"},
    {id = "9043134016", title = "Come Out Proud", artist = "Audio Library"},
    {id = "1841093287", title = "Horror Kit Hits 10", artist = "Horror"},
    {id = "1836289689", title = "Silly Chase Alt", artist = "Audio Library"},
    {id = "9044528192", title = "Deep Blue", artist = "Audio Library"},
    {id = "9044561348", title = "Hyperspeed", artist = "EDM"},
    {id = "9043434706", title = "Neon Lights", artist = "Synthwave"},
    {id = "9044460226", title = "City Nights", artist = "Lo-fi"},
    {id = "9043066771", title = "Rooftop Chill", artist = "Lo-fi"},
    {id = "9046885215", title = "Coffee Break", artist = "Lo-fi"},
    {id = "9046884968", title = "Study Time", artist = "Lo-fi"},
    {id = "9046884654", title = "Rainy Day", artist = "Lo-fi"},
    {id = "9046884312", title = "Midnight Drive", artist = "Lo-fi"},
    {id = "9046883978", title = "Ocean Waves", artist = "Ambient"},
    {id = "9046883614", title = "Sunset Boulevard", artist = "Lo-fi"},
    {id = "9046883251", title = "Starlight", artist = "Ambient"},

    -- ============================================
    -- 🎤 HIP HOP / RAP (30+)
    -- ============================================
    {id = "1839728052", title = "Sicko Mode", artist = "Travis Scott"},
    {id = "1839727961", title = "Goosebumps", artist = "Travis Scott"},
    {id = "1839727845", title = "Butterfly Effect", artist = "Travis Scott"},
    {id = "1839504614", title = "HUMBLE.", artist = "Kendrick Lamar"},
    {id = "1839504407", title = "DNA.", artist = "Kendrick Lamar"},
    {id = "1839504189", title = "Alright", artist = "Kendrick Lamar"},
    {id = "1839503944", title = "Money Trees", artist = "Kendrick Lamar"},
    {id = "1839727702", title = "Panda", artist = "Desiigner"},
    {id = "1839727389", title = "Bad and Boujee", artist = "Migos"},
    {id = "1839727225", title = "Versace", artist = "Migos"},
    {id = "1839727005", title = "Gucci Gang", artist = "Lil Pump"},
    {id = "1839726742", title = "Rockstar", artist = "Post Malone"},
    {id = "1839726564", title = "Congratulations", artist = "Post Malone"},
    {id = "1839726394", title = "White Iverson", artist = "Post Malone"},
    {id = "1839726205", title = "Psycho", artist = "Post Malone"},
    {id = "1839530790", title = "X Gon' Give It To Ya", artist = "DMX"},
    {id = "1839530578", title = "Ruff Ryders Anthem", artist = "DMX"},
    {id = "1839530293", title = "Lose Yourself", artist = "Eminem"},
    {id = "1839529975", title = "Rap God", artist = "Eminem"},
    {id = "1839529769", title = "Without Me", artist = "Eminem"},
    {id = "1839529450", title = "Not Afraid", artist = "Eminem"},

    -- ============================================
    -- 🎸 ROCK / METAL (40+)
    -- ============================================
    {id = "1836892715", title = "Believer", artist = "Imagine Dragons"},
    {id = "1836892494", title = "Thunder", artist = "Imagine Dragons"},
    {id = "1836892245", title = "Radioactive", artist = "Imagine Dragons"},
    {id = "1836892009", title = "Demons", artist = "Imagine Dragons"},
    {id = "1839491069", title = "Bohemian Rhapsody", artist = "Queen"},
    {id = "1839490856", title = "We Will Rock You", artist = "Queen"},
    {id = "1839490672", title = "Another One Bites the Dust", artist = "Queen"},
    {id = "1839490452", title = "Don't Stop Me Now", artist = "Queen"},
    {id = "1839489975", title = "Highway to Hell", artist = "AC/DC"},
    {id = "1839489761", title = "Back in Black", artist = "AC/DC"},
    {id = "1839489531", title = "Thunderstruck", artist = "AC/DC"},
    {id = "1839489207", title = "Sweet Child O' Mine", artist = "Guns N' Roses"},
    {id = "1839488951", title = "Welcome to the Jungle", artist = "Guns N' Roses"},
    {id = "1839488700", title = "November Rain", artist = "Guns N' Roses"},

    -- ============================================
    -- 🎺 JAZZ / BLUES (20+)
    -- ============================================
    {id = "1836808047", title = "Fly Me to the Moon", artist = "Frank Sinatra"},
    {id = "1836807776", title = "My Way", artist = "Frank Sinatra"},
    {id = "1836807524", title = "New York, New York", artist = "Frank Sinatra"},
    {id = "1836807278", title = "What a Wonderful World", artist = "Louis Armstrong"},
    {id = "1836807024", title = "Summertime", artist = "Ella Fitzgerald"},
    {id = "1836806789", title = "Autumn Leaves", artist = "Nat King Cole"},

    -- ============================================
    -- 🎼 K-POP (25+)
    -- ============================================
    {id = "6844912719", title = "Butter", artist = "BTS"},
    {id = "1894066752", title = "Fake Love", artist = "BTS"},
    {id = "1839820876", title = "Dynamite", artist = "BTS"},
    {id = "1839820621", title = "Boy With Luv", artist = "BTS"},
    {id = "1839820367", title = "DNA", artist = "BTS"},
    {id = "1839820118", title = "MIC Drop", artist = "BTS"},
    {id = "7551431783", title = "Money", artist = "LISA"},
    {id = "1839801892", title = "How You Like That", artist = "BLACKPINK"},
    {id = "1839801668", title = "Kill This Love", artist = "BLACKPINK"},
    {id = "1839801435", title = "DDU-DU DDU-DU", artist = "BLACKPINK"},
    {id = "1839801214", title = "Boombayah", artist = "BLACKPINK"},
    {id = "1839800994", title = "Whistle", artist = "BLACKPINK"},
    {id = "1839800765", title = "Playing with Fire", artist = "BLACKPINK"},

    -- ============================================
    -- 🎧 MISC / RANDOM (50+)
    -- ============================================
    {id = "9045764015", title = "Pop Sax", artist = "Audio Library"},
    {id = "9045763765", title = "Sunny Side", artist = "Audio Library"},
    {id = "9045763515", title = "Vibes Only", artist = "Audio Library"},
    {id = "9045763265", title = "Morning Coffee", artist = "Audio Library"},
    {id = "9045763015", title = "Easy Life", artist = "Audio Library"},
    {id = "9045762765", title = "Fresh Start", artist = "Audio Library"},
    {id = "9045762515", title = "New Day", artist = "Audio Library"},
    {id = "9045762265", title = "Positivity", artist = "Audio Library"},
    {id = "9045762015", title = "Good Times", artist = "Audio Library"},
    {id = "9045761765", title = "Celebrate", artist = "Audio Library"},
    }

-- ============================================
-- STATE
-- ============================================
local currentSound = nil
local currentIndex = 0
local isPlaying = false
local isExpanded = false

-- ============================================
-- SCREEN
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuszxMusicMobile"
ScreenGui.Parent = uiParent
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- ============================================
-- MINI PLAYER (FIX di bawah layar)
-- ============================================
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
MiniFrame.Size = UDim2.new(0, 340, 0, 62)
MiniFrame.Position = UDim2.new(0.5, -170, 1, -82)
MiniFrame.BackgroundColor3 = C.BG_LIGHT
MiniFrame.BorderSizePixel = 0
MiniFrame.Active = true
MiniFrame.Draggable = true
MiniFrame.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 10)
MiniCorner.Parent = MiniFrame

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(50, 50, 50)
MiniStroke.Thickness = 1
MiniStroke.Parent = MiniFrame

-- Progress bar TIPIS di ATAS mini player (kayak Spotify)
local TopProgressBg = Instance.new("Frame")
TopProgressBg.Size = UDim2.new(1, -20, 0, 2)
TopProgressBg.Position = UDim2.new(0, 10, 0, 0)
TopProgressBg.BackgroundColor3 = C.TRACK
TopProgressBg.BorderSizePixel = 0
TopProgressBg.Parent = MiniFrame

local TopProgressCorner = Instance.new("UICorner")
TopProgressCorner.CornerRadius = UDim.new(1, 0)
TopProgressCorner.Parent = TopProgressBg

local TopProgressFill = Instance.new("Frame")
TopProgressFill.Size = UDim2.new(0, 0, 1, 0)
TopProgressFill.BackgroundColor3 = C.WHITE
TopProgressFill.BorderSizePixel = 0
TopProgressFill.Parent = TopProgressBg

local TopProgressCorner2 = Instance.new("UICorner")
TopProgressCorner2.CornerRadius = UDim.new(1, 0)
TopProgressCorner2.Parent = TopProgressFill

-- Album Art (kiri)
local MiniAlbum = Instance.new("Frame")
MiniAlbum.Size = UDim2.new(0, 46, 0, 46)
MiniAlbum.Position = UDim2.new(0, 8, 0, 8)
MiniAlbum.BackgroundColor3 = C.CARD
MiniAlbum.BorderSizePixel = 0
MiniAlbum.Parent = MiniFrame

local MiniAlbumCorner = Instance.new("UICorner")
MiniAlbumCorner.CornerRadius = UDim.new(0, 6)
MiniAlbumCorner.Parent = MiniAlbum

local MiniAlbumIcon = Instance.new("TextLabel")
MiniAlbumIcon.Size = UDim2.new(1, 0, 1, 0)
MiniAlbumIcon.BackgroundTransparency = 1
MiniAlbumIcon.Text = "♪"
MiniAlbumIcon.TextColor3 = C.GREEN
MiniAlbumIcon.Font = Enum.Font.GothamBold
MiniAlbumIcon.TextSize = 22
MiniAlbumIcon.Parent = MiniAlbum

-- Title
local MiniTitle = Instance.new("TextLabel")
MiniTitle.Size = UDim2.new(1, -230, 0, 16)
MiniTitle.Position = UDim2.new(0, 62, 0, 14)
MiniTitle.BackgroundTransparency = 1
MiniTitle.Text = "Pilih lagu..."
MiniTitle.TextColor3 = C.WHITE
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.TextSize = 12
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
MiniTitle.TextTruncate = Enum.TextTruncate.AtEnd
MiniTitle.Parent = MiniFrame

-- Artist
local MiniArtist = Instance.new("TextLabel")
MiniArtist.Size = UDim2.new(1, -230, 0, 14)
MiniArtist.Position = UDim2.new(0, 62, 0, 32)
MiniArtist.BackgroundTransparency = 1
MiniArtist.Text = "—"
MiniArtist.TextColor3 = C.GRAY
MiniArtist.Font = Enum.Font.GothamMedium
MiniArtist.TextSize = 10
MiniArtist.TextXAlignment = Enum.TextXAlignment.Left
MiniArtist.TextTruncate = Enum.TextTruncate.AtEnd
MiniArtist.Parent = MiniFrame

-- ========== KONTROL (kanan, compact) ==========
-- Prev
local PrevBtn = Instance.new("TextButton")
PrevBtn.Size = UDim2.new(0, 28, 0, 28)
PrevBtn.Position = UDim2.new(1, -160, 0, 17)
PrevBtn.BackgroundTransparency = 1
PrevBtn.Text = "⏮"
PrevBtn.TextColor3 = C.WHITE
PrevBtn.Font = Enum.Font.GothamBold
PrevBtn.TextSize = 16
PrevBtn.BorderSizePixel = 0
PrevBtn.AutoButtonColor = false
PrevBtn.Parent = MiniFrame

-- Play/Pause (1 tombol)
local PlayBtn = Instance.new("TextButton")
PlayBtn.Size = UDim2.new(0, 34, 0, 34)
PlayBtn.Position = UDim2.new(1, -128, 0, 14)
PlayBtn.BackgroundColor3 = C.WHITE
PlayBtn.Text = "▶"
PlayBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PlayBtn.Font = Enum.Font.GothamBold
PlayBtn.TextSize = 16
PlayBtn.BorderSizePixel = 0
PlayBtn.AutoButtonColor = false
PlayBtn.Parent = MiniFrame

local PlayCorner = Instance.new("UICorner")
PlayCorner.CornerRadius = UDim.new(1, 0)
PlayCorner.Parent = PlayBtn

-- Next
local NextBtn = Instance.new("TextButton")
NextBtn.Size = UDim2.new(0, 28, 0, 28)
NextBtn.Position = UDim2.new(1, -90, 0, 17)
NextBtn.BackgroundTransparency = 1
NextBtn.Text = "⏭"
NextBtn.TextColor3 = C.WHITE
NextBtn.Font = Enum.Font.GothamBold
NextBtn.TextSize = 16
NextBtn.BorderSizePixel = 0
NextBtn.AutoButtonColor = false
NextBtn.Parent = MiniFrame

-- Expand (▲)
local ExpandBtn = Instance.new("TextButton")
ExpandBtn.Size = UDim2.new(0, 26, 0, 26)
ExpandBtn.Position = UDim2.new(1, -56, 0, 18)
ExpandBtn.BackgroundTransparency = 1
ExpandBtn.Text = "▲"
ExpandBtn.TextColor3 = C.WHITE
ExpandBtn.Font = Enum.Font.GothamBold
ExpandBtn.TextSize = 12
ExpandBtn.BorderSizePixel = 0
ExpandBtn.AutoButtonColor = false
ExpandBtn.Parent = MiniFrame

-- ============================================
-- EXPANDED PANEL (playlist)
-- ============================================
local ExpandedFrame = Instance.new("Frame")
ExpandedFrame.Name = "ExpandedFrame"
ExpandedFrame.Size = UDim2.new(0, 340, 0, 400)
ExpandedFrame.Position = UDim2.new(0.5, -170, 1, -482)
ExpandedFrame.BackgroundColor3 = C.BG
ExpandedFrame.BorderSizePixel = 0
ExpandedFrame.Visible = false
ExpandedFrame.Active = true
ExpandedFrame.Parent = ScreenGui

local ExpCorner = Instance.new("UICorner")
ExpCorner.CornerRadius = UDim.new(0, 10)
ExpCorner.Parent = ExpandedFrame

local ExpStroke = Instance.new("UIStroke")
ExpStroke.Color = Color3.fromRGB(50, 50, 50)
ExpStroke.Thickness = 1
ExpStroke.Parent = ExpandedFrame

-- Header
local ExpHeader = Instance.new("Frame")
ExpHeader.Size = UDim2.new(1, 0, 0, 42)
ExpHeader.BackgroundColor3 = C.BG_LIGHT
ExpHeader.BorderSizePixel = 0
ExpHeader.Parent = ExpandedFrame

local ExpHeaderCorner = Instance.new("UICorner")
ExpHeaderCorner.CornerRadius = UDim.new(0, 10)
ExpHeaderCorner.Parent = ExpHeader

local ExpLogo = Instance.new("Frame")
ExpLogo.Size = UDim2.new(0, 26, 0, 26)
ExpLogo.Position = UDim2.new(0, 10, 0, 8)
ExpLogo.BackgroundColor3 = C.GREEN
ExpLogo.BorderSizePixel = 0
ExpLogo.Parent = ExpHeader

local ExpLogoCorner = Instance.new("UICorner")
ExpLogoCorner.CornerRadius = UDim.new(1, 0)
ExpLogoCorner.Parent = ExpLogo

local ExpLogoText = Instance.new("TextLabel")
ExpLogoText.Size = UDim2.new(1, 0, 1, 0)
ExpLogoText.BackgroundTransparency = 1
ExpLogoText.Text = "♪"
ExpLogoText.TextColor3 = Color3.fromRGB(0, 0, 0)
ExpLogoText.Font = Enum.Font.GothamBold
ExpLogoText.TextSize = 16
ExpLogoText.Parent = ExpLogo

local ExpTitle = Instance.new("TextLabel")
ExpTitle.Size = UDim2.new(1, -80, 1, 0)
ExpTitle.Position = UDim2.new(0, 44, 0, 0)
ExpTitle.BackgroundTransparency = 1
ExpTitle.Text = "Yuszx Music"
ExpTitle.TextColor3 = C.WHITE
ExpTitle.Font = Enum.Font.GothamBold
ExpTitle.TextSize = 14
ExpTitle.TextXAlignment = Enum.TextXAlignment.Left
ExpTitle.Parent = ExpHeader

local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
CollapseBtn.Position = UDim2.new(1, -36, 0, 6)
CollapseBtn.BackgroundTransparency = 1
CollapseBtn.Text = "▼"
CollapseBtn.TextColor3 = C.WHITE
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 12
CollapseBtn.BorderSizePixel = 0
CollapseBtn.AutoButtonColor = false
CollapseBtn.Parent = ExpHeader

-- Now Playing (expanded)
local ExpNowPlaying = Instance.new("Frame")
ExpNowPlaying.Size = UDim2.new(1, -20, 0, 70)
ExpNowPlaying.Position = UDim2.new(0, 10, 0, 50)
ExpNowPlaying.BackgroundColor3 = C.BG_LIGHT
ExpNowPlaying.BorderSizePixel = 0
ExpNowPlaying.Parent = ExpandedFrame

local ExpNP_Corner = Instance.new("UICorner")
ExpNP_Corner.CornerRadius = UDim.new(0, 8)
ExpNP_Corner.Parent = ExpNowPlaying

local ExpAlbum = Instance.new("Frame")
ExpAlbum.Size = UDim2.new(0, 54, 0, 54)
ExpAlbum.Position = UDim2.new(0, 8, 0, 8)
ExpAlbum.BackgroundColor3 = C.CARD
ExpAlbum.BorderSizePixel = 0
ExpAlbum.Parent = ExpNowPlaying

local ExpAlbumCorner = Instance.new("UICorner")
ExpAlbumCorner.CornerRadius = UDim.new(0, 6)
ExpAlbumCorner.Parent = ExpAlbum

local ExpAlbumIcon = Instance.new("TextLabel")
ExpAlbumIcon.Size = UDim2.new(1, 0, 1, 0)
ExpAlbumIcon.BackgroundTransparency = 1
ExpAlbumIcon.Text = "🎵"
ExpAlbumIcon.TextColor3 = C.GREEN
ExpAlbumIcon.Font = Enum.Font.GothamBold
ExpAlbumIcon.TextSize = 26
ExpAlbumIcon.Parent = ExpAlbum

local ExpSongTitle = Instance.new("TextLabel")
ExpSongTitle.Size = UDim2.new(1, -80, 0, 18)
ExpSongTitle.Position = UDim2.new(0, 70, 0, 10)
ExpSongTitle.BackgroundTransparency = 1
ExpSongTitle.Text = "Pilih lagu..."
ExpSongTitle.TextColor3 = C.WHITE
ExpSongTitle.Font = Enum.Font.GothamBold
ExpSongTitle.TextSize = 12
ExpSongTitle.TextXAlignment = Enum.TextXAlignment.Left
ExpSongTitle.TextTruncate = Enum.TextTruncate.AtEnd
ExpSongTitle.Parent = ExpNowPlaying

local ExpSongArtist = Instance.new("TextLabel")
ExpSongArtist.Size = UDim2.new(1, -80, 0, 14)
ExpSongArtist.Position = UDim2.new(0, 70, 0, 30)
ExpSongArtist.BackgroundTransparency = 1
ExpSongArtist.Text = "—"
ExpSongArtist.TextColor3 = C.GRAY
ExpSongArtist.Font = Enum.Font.GothamMedium
ExpSongArtist.TextSize = 10
ExpSongArtist.TextXAlignment = Enum.TextXAlignment.Left
ExpSongArtist.TextTruncate = Enum.TextTruncate.AtEnd
ExpSongArtist.Parent = ExpNowPlaying

local ExpSongId = Instance.new("TextLabel")
ExpSongId.Size = UDim2.new(1, -80, 0, 12)
ExpSongId.Position = UDim2.new(0, 70, 0, 48)
ExpSongId.BackgroundTransparency = 1
ExpSongId.Text = ""
ExpSongId.TextColor3 = C.DIM
ExpSongId.Font = Enum.Font.Code
ExpSongId.TextSize = 9
ExpSongId.TextXAlignment = Enum.TextXAlignment.Left
ExpSongId.Parent = ExpNowPlaying

-- Controls row (expanded)
local ExpControls = Instance.new("Frame")
ExpControls.Size = UDim2.new(1, -20, 0, 40)
ExpControls.Position = UDim2.new(0, 10, 0, 128)
ExpControls.BackgroundTransparency = 1
ExpControls.Parent = ExpandedFrame

local ExpCtrlLayout = Instance.new("UIListLayout")
ExpCtrlLayout.FillDirection = Enum.FillDirection.Horizontal
ExpCtrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ExpCtrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ExpCtrlLayout.Padding = UDim.new(0, 12)
ExpCtrlLayout.Parent = ExpControls

local function makeExpCtrl(text, size, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, size, 0, size)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = C.WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = size > 30 and 18 or 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = ExpControls
    btn.MouseButton1Click:Connect(callback)
    return btn
end

makeExpCtrl("🔀", 28, function()
    local s = not Config.get("Shuffle", false)
    Config.set("Shuffle", s)
end)
makeExpCtrl("⏮", 32, function() playPrev() end)
local ExpPlayBtn = makeExpCtrl("▶", 40, function() togglePlay() end)
makeExpCtrl("⏭", 32, function() playNext() end)
makeExpCtrl("🔁", 28, function()
    local l = not Config.get("Loop", false)
    Config.set("Loop", l)
    if currentSound then currentSound.Looped = l end
end)

-- Volume
local VolFrame = Instance.new("Frame")
VolFrame.Size = UDim2.new(1, -20, 0, 22)
VolFrame.Position = UDim2.new(0, 10, 0, 172)
VolFrame.BackgroundTransparency = 1
VolFrame.Parent = ExpandedFrame

local VolIcon = Instance.new("TextLabel")
VolIcon.Size = UDim2.new(0, 20, 1, 0)
VolIcon.BackgroundTransparency = 1
VolIcon.Text = "🔊"
VolIcon.TextColor3 = C.GRAY
VolIcon.Font = Enum.Font.GothamBold
VolIcon.TextSize = 12
VolIcon.Parent = VolFrame

local VolBarBg = Instance.new("Frame")
VolBarBg.Size = UDim2.new(1, -50, 0, 4)
VolBarBg.Position = UDim2.new(0, 24, 0, 9)
VolBarBg.BackgroundColor3 = C.TRACK
VolBarBg.BorderSizePixel = 0
VolBarBg.Parent = VolFrame

local VolBarCorner = Instance.new("UICorner")
VolBarCorner.CornerRadius = UDim.new(1, 0)
VolBarCorner.Parent = VolBarBg

local VolFill = Instance.new("Frame")
VolFill.Size = UDim2.new(Config.get("Volume", 0.5), 0, 1, 0)
VolFill.BackgroundColor3 = C.WHITE
VolFill.BorderSizePixel = 0
VolFill.Parent = VolBarBg

local VolFillCorner = Instance.new("UICorner")
VolFillCorner.CornerRadius = UDim.new(1, 0)
VolFillCorner.Parent = VolFill

local VolKnob = Instance.new("TextButton")
VolKnob.Size = UDim2.new(0, 10, 0, 10)
VolKnob.Position = UDim2.new(Config.get("Volume", 0.5), -5, 0, -3)
VolKnob.BackgroundColor3 = C.WHITE
VolKnob.Text = ""
VolKnob.BorderSizePixel = 0
VolKnob.AutoButtonColor = false
VolKnob.Parent = VolBarBg

local VolKnobCorner = Instance.new("UICorner")
VolKnobCorner.CornerRadius = UDim.new(1, 0)
VolKnobCorner.Parent = VolKnob

-- Search
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, -20, 0, 30)
SearchFrame.Position = UDim2.new(0, 10, 0, 202)
SearchFrame.BackgroundColor3 = C.BG_LIGHT
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = ExpandedFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 15)
SearchCorner.Parent = SearchFrame

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 24, 1, 0)
SearchIcon.Position = UDim2.new(0, 8, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = C.GRAY
SearchIcon.TextSize = 11
SearchIcon.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -38, 1, 0)
SearchBox.Position = UDim2.new(0, 34, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Cari lagu atau artis..."
SearchBox.PlaceholderColor3 = C.DIM
SearchBox.TextColor3 = C.WHITE
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 11
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

-- Playlist
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(1, -20, 1, -250)
ListFrame.Position = UDim2.new(0, 10, 0, 240)
ListFrame.BackgroundColor3 = C.BG_LIGHT
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 3
ListFrame.ScrollBarImageColor3 = C.GREEN
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.Parent = ExpandedFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = ListFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 2)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ListFrame

local ListPad = Instance.new("UIPadding")
ListPad.PaddingTop = UDim.new(0, 6)
ListPad.PaddingLeft = UDim.new(0, 6)
ListPad.PaddingRight = UDim.new(0, 6)
ListPad.PaddingBottom = UDim.new(0, 6)
ListPad.Parent = ListFrame

-- ============================================
-- PLAYER LOGIC
-- ============================================
local function stopCurrent()
    if currentSound then
        pcall(function()
            currentSound:Stop()
            currentSound:Destroy()
        end)
        currentSound = nil
    end
    isPlaying = false
end

local function createSound(id)
    local sound = Instance.new("Sound")
    sound.Name = "YuszxMusic"
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = Config.get("Volume", 0.5)
    sound.Looped = Config.get("Loop", false)
    local parents = {soundParent, game:GetService("SoundService"), workspace}
    for _, p in ipairs(parents) do
        if p then
            local ok = pcall(function() sound.Parent = p end)
            if ok and sound.Parent then break end
        end
    end
    return sound
end

local function updateNowPlaying()
    if currentIndex >= 1 and currentIndex <= #PLAYLIST then
        local song = PLAYLIST[currentIndex]
        MiniTitle.Text = song.title
        MiniArtist.Text = song.artist or "Unknown"
        ExpSongTitle.Text = song.title
        ExpSongArtist.Text = song.artist or "Unknown"
        ExpSongId.Text = "📻 Sound ID: " .. song.id
    end
end

local function playSong(index)
    if index < 1 or index > #PLAYLIST then return end
    stopCurrent()
    currentIndex = index
    local song = PLAYLIST[index]
    
    local sound = createSound(song.id)
    sound:Play()
    currentSound = sound
    isPlaying = true
    PlayBtn.Text = "⏸"
    ExpPlayBtn.Text = "⏸"
    
    sound.Ended:Connect(function()
        if Config.get("Loop", false) then return end
        if not isPlaying then return end
        currentIndex = currentIndex + 1
        if currentIndex > #PLAYLIST then currentIndex = 1 end
        playSong(currentIndex)
        updateNowPlaying()
    end)
end

function playNext()
    if #PLAYLIST == 0 then return end
    if Config.get("Shuffle", false) then
        currentIndex = math.random(1, #PLAYLIST)
    else
        currentIndex = currentIndex + 1
        if currentIndex > #PLAYLIST then currentIndex = 1 end
    end
    playSong(currentIndex)
    updateNowPlaying()
end

function playPrev()
    if #PLAYLIST == 0 then return end
    currentIndex = currentIndex - 1
    if currentIndex < 1 then currentIndex = #PLAYLIST end
    playSong(currentIndex)
    updateNowPlaying()
end

function togglePlay()
    if currentSound then
        if isPlaying then
            currentSound:Pause()
            isPlaying = false
            PlayBtn.Text = "▶"
            ExpPlayBtn.Text = "▶"
        else
            currentSound:Resume()
            isPlaying = true
            PlayBtn.Text = "⏸"
            ExpPlayBtn.Text = "⏸"
        end
    else
        playSong(1)
        updateNowPlaying()
    end
end

-- ============================================
-- PLAYLIST ROWS
-- ============================================
local function refreshList()
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local filter = string.lower(SearchBox.Text or "")
    
    for i, song in ipairs(PLAYLIST) do
        local t = string.lower(song.title)
        local a = string.lower(song.artist or "")
        if filter == "" or string.find(t, filter, 1, true) or string.find(a, filter, 1, true) then
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, 0, 0, 38)
            row.BackgroundColor3 = C.BG
            row.BackgroundTransparency = 1
            row.Text = ""
            row.BorderSizePixel = 0
            row.AutoButtonColor = false
            row.Parent = ListFrame
            
            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(0, 6)
            rc.Parent = row
            
            local miniArt = Instance.new("Frame")
            miniArt.Size = UDim2.new(0, 26, 0, 26)
            miniArt.Position = UDim2.new(0, 6, 0, 6)
            miniArt.BackgroundColor3 = C.CARD
            miniArt.BorderSizePixel = 0
            miniArt.Parent = row
            
            local mac = Instance.new("UICorner")
            mac.CornerRadius = UDim.new(0, 4)
            mac.Parent = miniArt
            
            local maIcon = Instance.new("TextLabel")
            maIcon.Size = UDim2.new(1, 0, 1, 0)
            maIcon.BackgroundTransparency = 1
            maIcon.Text = "♪"
            maIcon.TextColor3 = C.GREEN
            maIcon.Font = Enum.Font.GothamBold
            maIcon.TextSize = 13
            maIcon.Parent = miniArt
            
            local rTitle = Instance.new("TextLabel")
            rTitle.Size = UDim2.new(1, -50, 0, 15)
            rTitle.Position = UDim2.new(0, 40, 0, 4)
            rTitle.BackgroundTransparency = 1
            rTitle.Text = song.title
            rTitle.TextColor3 = C.WHITE
            rTitle.Font = Enum.Font.GothamMedium
            rTitle.TextSize = 11
            rTitle.TextXAlignment = Enum.TextXAlignment.Left
            rTitle.TextTruncate = Enum.TextTruncate.AtEnd
            rTitle.Parent = row
            
            local rArtist = Enum.Font.GothamMedium
            local rArtistLabel = Instance.new("TextLabel")
            rArtistLabel.Size = UDim2.new(1, -50, 0, 13)
            rArtistLabel.Position = UDim2.new(0, 40, 0, 20)
            rArtistLabel.BackgroundTransparency = 1
            rArtistLabel.Text = song.artist or "Unknown"
            rArtistLabel.TextColor3 = C.GRAY
            rArtistLabel.Font = rArtist
            rArtistLabel.TextSize = 9
            rArtistLabel.TextXAlignment = Enum.TextXAlignment.Left
            rArtistLabel.TextTruncate = Enum.TextTruncate.AtEnd
            rArtistLabel.Parent = row
            
            row.MouseEnter:Connect(function() row.BackgroundTransparency = 0 end)
            row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)
            row.MouseButton1Click:Connect(function()
                playSong(i)
                updateNowPlaying()
            end)
        end
    end
    
    task.wait(0.05)
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)

-- ============================================
-- PROGRESS UPDATE LOOP
-- ============================================
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.1)
        pcall(function()
            if currentSound and currentSound.Parent and currentSound.IsPlaying then
                local length = currentSound.TimeLength
                local pos = currentSound.TimePosition
                if length > 0 then
                    TopProgressFill.Size = UDim2.new(math.clamp(pos / length, 0, 1), 0, 1, 0)
                end
            end
        end)
    end
end)

-- ============================================
-- HANDLERS
-- ============================================
PlayBtn.MouseButton1Click:Connect(togglePlay)
PrevBtn.MouseButton1Click:Connect(function() playPrev(); updateNowPlaying() end)
NextBtn.MouseButton1Click:Connect(function() playNext(); updateNowShowing = nil; updateNowPlaying() end)

ExpandBtn.MouseButton1Click:Connect(function()
    isExpanded = true
    ExpandedFrame.Visible = true
    MiniFrame.Visible = false
    refreshList()
end)

CollapseBtn.MouseButton1Click:Connect(function()
    isExpanded = false
    ExpandedFrame.Visible = false
    MiniFrame.Visible = true
end)

-- ============================================
-- VOLUME SLIDER
-- ============================================
local draggingVol = false

VolKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingVol = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if draggingVol then
            draggingVol = false
            Config.set("Volume", tonumber(VolFill.Size.X.Scale) or 0.5)
        end
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if not draggingVol then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local relX = input.Position.X - VolBarBg.AbsolutePosition.X
    local pct = math.clamp(relX / VolBarBg.AbsoluteSize.X, 0, 1)
    VolFill.Size = UDim2.new(pct, 0, 1, 0)
    VolKnob.Position = UDim2.new(pct, -5, 0, -3)
    if currentSound then currentSound.Volume = pct end
end)

VolBarBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local relX = input.Position.X - VolBarBg.AbsolutePosition.X
        local pct = math.clamp(relX / VolBarBg.AbsoluteSize.X, 0, 1)
        VolFill.Size = UDim2.new(pct, 0, 1, 0)
        VolKnob.Position = UDim2.new(pct, -5, 0, -3)
        Config.set("Volume", pct)
        if currentSound then currentSound.Volume = pct end
    end
end)

-- ============================================
-- HANDLE RESPAWN
-- ============================================
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if currentSound and not currentSound.Parent and currentIndex > 0 then
        local wasPlaying = isPlaying
        local sound = createSound(PLAYLIST[currentIndex].id)
        currentSound = sound
        if wasPlaying then sound:Play() end
    end
end)

-- ============================================
-- INIT
-- ============================================
refreshList()
print("[Yuszx] 🎵 Mobile Spotify loaded! " .. #PLAYLIST .. " lagu")
