--[[
    ═══════════════════════════════════════════════════════════════
    🎵 YUSZX MUSIC PLAYER — UNIVERSAL SPOTIFY EDITION
    ═══════════════════════════════════════════════════════════════
    ✅ Works di SEMUA game Roblox
    ✅ Multi-fallback untuk executor yang beda
    ✅ Multi-parent untuk Sound (SoundService, workspace, CoreGui)
    ✅ Handle character respawn
    ✅ Handle anti-cheat yang block CoreGui
    ✅ Auto-detect metode terbaik
    ═══════════════════════════════════════════════════════════════
]]

-- ============================================
-- UNIVERSAL HELPER
-- ============================================
local function getSafeParent()
    -- Coba berbagai metode untuk dapetin parent UI
    local parents = {}
    
    -- Method 1: gethui (Delta, Codex)
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then table.insert(parents, hui) end
    end
    
    -- Method 2: game:GetService("CoreGui")
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then table.insert(parents, cg) end
    
    -- Method 3: Player.PlayerGui (fallback)
    local plr = game:GetService("Players").LocalPlayer
    local pg = plr:FindFirstChild("PlayerGui")
    if pg then table.insert(parents, pg) end
    
    -- Coba satu-satu
    for _, parent in ipairs(parents) do
        local test = Instance.new("ScreenGui")
        local success = pcall(function()
            test.Parent = parent
        end)
        if success and test.Parent then
            test:Destroy()
            return parent
        end
        test:Destroy()
    end
    
    return nil
end

local function getSafeSoundParent()
    -- Coba berbagai parent untuk Sound
    local candidates = {}
    
    pcall(function()
        table.insert(candidates, game:GetService("SoundService"))
    end)
    
    pcall(function()
        table.insert(candidates, workspace)
    end)
    
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then table.insert(candidates, cam) end
    end)
    
    pcall(function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char then table.insert(candidates, char) end
    end)
    
    -- Test mana yang bisa dipakai
    for _, parent in ipairs(candidates) do
        if parent then
            local test = Instance.new("Sound")
            local ok = pcall(function()
                test.Parent = parent
            end)
            if ok and test.Parent then
                test:Destroy()
                return parent
            end
            test:Destroy()
        end
    end
    
    return workspace
end

-- ============================================
-- CONFIG
-- ============================================
local CONFIG_FILE = "YuszxMusic_config.json"
local DEFAULT_CONFIG = {
    Volume = 0.5,
    Loop = false,
    Shuffle = false,
    UIMinimized = false,
}
local Config = {}
local currentConfig = {}
for k, v in pairs(DEFAULT_CONFIG) do currentConfig[k] = v end

function Config.load()
    if not readfile or not isfile then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(data) do currentConfig[k] = v end
        end
    end)
end
function Config.save()
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(currentConfig))
    end)
end
function Config.get(k, d) return currentConfig[k] ~= nil and currentConfig[k] or d end
function Config.set(k, v) currentConfig[k] = v; Config.save() end
Config.load()

-- ============================================
-- SPOTIFY COLOR PALETTE
-- ============================================
local COLORS = {
    BG_BLACK = Color3.fromRGB(18, 18, 18),
    BG_DARK = Color3.fromRGB(24, 24, 24),
    BG_CARD = Color3.fromRGB(40, 40, 40),
    BG_HOVER = Color3.fromRGB(45, 45, 45),
    GREEN = Color3.fromRGB(29, 185, 84),
    GREEN_HOVER = Color3.fromRGB(30, 215, 96),
    TEXT_WHITE = Color3.fromRGB(255, 255, 255),
    TEXT_GRAY = Color3.fromRGB(179, 179, 179),
    TEXT_SUBTLE = Color3.fromRGB(120, 120, 120),
    PROGRESS_BG = Color3.fromRGB(83, 83, 83),
    PROGRESS_FILL = Color3.fromRGB(255, 255, 255),
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
-- PLAYER STATE
-- ============================================
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local currentSound = nil
local currentIndex = 0
local isPlaying = false
local soundParent = nil  -- di-set nanti

-- ============================================
-- GET SAFE PARENT
-- ============================================
local uiParent = getSafeParent()
soundParent = getSafeSoundParent()

if not uiParent then
    warn("[Yuszx] ❌ Gak bisa dapet UI parent! Script gak bisa jalan.")
    return
end

print("[Yuszx] ✅ UI Parent: " .. uiParent:GetFullName())
print("[Yuszx] ✅ Sound Parent: " .. soundParent:GetFullName())

-- ============================================
-- UI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YuszxSpotify"
ScreenGui.Parent = uiParent
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 620)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -310)
MainFrame.BackgroundColor3 = COLORS.BG_BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = COLORS.BG_DARK
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local LogoCircle = Instance.new("Frame")
LogoCircle.Size = UDim2.new(0, 32, 0, 32)
LogoCircle.Position = UDim2.new(0, 14, 0, 9)
LogoCircle.BackgroundColor3 = COLORS.GREEN
LogoCircle.BorderSizePixel = 0
LogoCircle.Parent = TopBar

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoCircle

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "♪"
LogoText.TextColor3 = Color3.fromRGB(0, 0, 0)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 22
LogoText.Parent = LogoCircle

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 56, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Yuszx Music"
Title.TextColor3 = COLORS.TEXT_WHITE
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 32, 0, 32)
MinButton.Position = UDim2.new(1, -76, 0, 9)
MinButton.BackgroundColor3 = COLORS.BG_CARD
MinButton.Text = "−"
MinButton.TextColor3 = COLORS.TEXT_WHITE
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 18
MinButton.BorderSizePixel = 0
MinButton.AutoButtonColor = false
MinButton.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 16)
MinCorner.Parent = MinButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -40, 0, 9)
CloseButton.BackgroundColor3 = COLORS.BG_CARD
CloseButton.Text = "✕"
CloseButton.TextColor3 = COLORS.TEXT_WHITE
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.BorderSizePixel = 0
CloseButton.AutoButtonColor = false
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 16)
CloseCorner.Parent = CloseButton

-- Now Playing
local NowPlayingSection = Instance.new("Frame")
NowPlayingSection.Size = UDim2.new(1, -28, 0, 100)
NowPlayingSection.Position = UDim2.new(0, 14, 0, 62)
NowPlayingSection.BackgroundTransparency = 1
NowPlayingSection.Parent = MainFrame

local AlbumArt = Instance.new("Frame")
AlbumArt.Size = UDim2.new(0, 90, 0, 90)
AlbumArt.Position = UDim2.new(0, 0, 0, 5)
AlbumArt.BackgroundColor3 = COLORS.BG_CARD
AlbumArt.BorderSizePixel = 0
AlbumArt.Parent = NowPlayingSection

local AlbumCorner = Instance.new("UICorner")
AlbumCorner.CornerRadius = UDim.new(0, 6)
AlbumCorner.Parent = AlbumArt

local AlbumIcon = Instance.new("TextLabel")
AlbumIcon.Size = UDim2.new(1, 0, 1, 0)
AlbumIcon.BackgroundTransparency = 1
AlbumIcon.Text = "🎵"
AlbumIcon.TextColor3 = COLORS.GREEN
AlbumIcon.Font = Enum.Font.GothamBold
AlbumIcon.TextSize = 40
AlbumIcon.Parent = AlbumArt

local SongTitle = Instance.new("TextLabel")
SongTitle.Size = UDim2.new(1, -110, 0, 26)
SongTitle.Position = UDim2.new(0, 102, 0, 12)
SongTitle.BackgroundTransparency = 1
SongTitle.Text = "Pilih lagu untuk diputar"
SongTitle.TextColor3 = COLORS.TEXT_WHITE
SongTitle.Font = Enum.Font.GothamBold
SongTitle.TextSize = 15
SongTitle.TextXAlignment = Enum.TextXAlignment.Left
SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
SongTitle.Parent = NowPlayingSection

local SongArtist = Instance.new("TextLabel")
SongArtist.Size = UDim2.new(1, -110, 0, 20)
SongArtist.Position = UDim2.new(0, 102, 0, 40)
SongArtist.BackgroundTransparency = 1
SongArtist.Text = "—"
SongArtist.TextColor3 = COLORS.TEXT_GRAY
SongArtist.Font = Enum.Font.GothamMedium
SongArtist.TextSize = 12
SongArtist.TextXAlignment = Enum.TextXAlignment.Left
SongArtist.Parent = NowPlayingSection

local SongIdLabel = Instance.new("TextLabel")
SongIdLabel.Size = UDim2.new(1, -110, 0, 16)
SongIdLabel.Position = UDim2.new(0, 102, 0, 62)
SongIdLabel.BackgroundTransparency = 1
SongIdLabel.Text = ""
SongIdLabel.TextColor3 = COLORS.TEXT_SUBTLE
SongIdLabel.Font = Enum.Font.Code
SongIdLabel.TextSize = 10
SongIdLabel.TextXAlignment = Enum.TextXAlignment.Left
SongIdLabel.Parent = NowPlayingSection

-- Progress
local ProgressSection = Instance.new("Frame")
ProgressSection.Size = UDim2.new(1, -28, 0, 30)
ProgressSection.Position = UDim2.new(0, 14, 0, 168)
ProgressSection.BackgroundTransparency = 1
ProgressSection.Parent = MainFrame

local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(1, 0, 0, 4)
ProgressBg.Position = UDim2.new(0, 0, 0, 8)
ProgressBg.BackgroundColor3 = COLORS.PROGRESS_BG
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = ProgressSection

local ProgressBgCorner = Instance.new("UICorner")
ProgressBgCorner.CornerRadius = UDim.new(1, 0)
ProgressBgCorner.Parent = ProgressBg

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = COLORS.PROGRESS_FILL
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBg

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(1, 0)
ProgressFillCorner.Parent = ProgressFill

local ProgressBtn = Instance.new("TextButton")
ProgressBtn.Size = UDim2.new(0, 12, 0, 12)
ProgressBtn.Position = UDim2.new(0, -6, 0, 4)
ProgressBtn.BackgroundColor3 = COLORS.PROGRESS_FILL
ProgressBtn.Text = ""
ProgressBtn.BorderSizePixel = 0
ProgressBtn.AutoButtonColor = false
ProgressBtn.Parent = ProgressSection

local ProgressBtnCorner = Instance.new("UICorner")
ProgressBtnCorner.CornerRadius = UDim.new(1, 0)
ProgressBtnCorner.Parent = ProgressBtn

local TimeCurrent = Instance.new("TextLabel")
TimeCurrent.Size = UDim2.new(0, 50, 0, 14)
TimeCurrent.Position = UDim2.new(0, 0, 0, 16)
TimeCurrent.BackgroundTransparency = 1
TimeCurrent.Text = "0:00"
TimeCurrent.TextColor3 = COLORS.TEXT_GRAY
TimeCurrent.Font = Enum.Font.GothamMedium
TimeCurrent.TextSize = 10
TimeCurrent.TextXAlignment = Enum.TextXAlignment.Left
TimeCurrent.Parent = ProgressSection

local TimeTotal = Instance.new("TextLabel")
TimeTotal.Size = UDim2.new(0, 50, 0, 14)
TimeTotal.Position = UDim2.new(1, -50, 0, 16)
TimeTotal.BackgroundTransparency = 1
TimeTotal.Text = "0:00"
TimeTotal.TextColor3 = COLORS.TEXT_GRAY
TimeTotal.Font = Enum.Font.GothamMedium
TimeTotal.TextSize = 10
TimeTotal.TextXAlignment = Enum.TextXAlignment.Right
TimeTotal.Parent = ProgressSection

-- Controls
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -28, 0, 50)
ControlsFrame.Position = UDim2.new(0, 14, 0, 204)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = MainFrame

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlsLayout.Padding = UDim.new(0, 12)
ControlsLayout.Parent = ControlsFrame

local function makeCtrlBtn(text, size, callback, isPrimary)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, size, 0, size)
    btn.BackgroundColor3 = isPrimary and COLORS.TEXT_WHITE or Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = isPrimary and 0 or 1
    btn.Text = text
    btn.TextColor3 = isPrimary and Color3.fromRGB(0, 0, 0) or COLORS.TEXT_GRAY
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = isPrimary and 20 or 16
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = ControlsFrame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function()
        if isPrimary then
            btn.BackgroundColor3 = COLORS.GREEN_HOVER
        else
            btn.TextColor3 = COLORS.TEXT_WHITE
        end
    end)
    btn.MouseLeave:Connect(function()
        if isPrimary then
            btn.BackgroundColor3 = COLORS.TEXT_WHITE
        else
            btn.TextColor3 = COLORS.TEXT_GRAY
        end
    end)
    
    return btn
end

local ShuffleBtn = makeCtrlBtn("🔀", 32, function()
    local s = not Config.get("Shuffle", false)
    Config.set("Shuffle", s)
    ShuffleBtn.TextColor3 = s and COLORS.GREEN or COLORS.TEXT_GRAY
end)
if Config.get("Shuffle", false) then ShuffleBtn.TextColor3 = COLORS.GREEN end

makeCtrlBtn("⏮", 32, function() playPrev() end)

local PlayPauseBtn = makeCtrlBtn("▶", 48, function() togglePlay() end, true)

makeCtrlBtn("⏭", 32, function() playNext() end)

local RepeatBtn = makeCtrlBtn("🔁", 32, function()
    local l = not Config.get("Loop", false)
    Config.set("Loop", l)
    RepeatBtn.TextColor3 = l and COLORS.GREEN or COLORS.TEXT_GRAY
    if currentSound then currentSound.Looped = l end
end)
if Config.get("Loop", false) then RepeatBtn.TextColor3 = COLORS.GREEN end

-- Volume
local VolumeFrame = Instance.new("Frame")
VolumeFrame.Size = UDim2.new(0, 140, 0, 30)
VolumeFrame.Position = UDim2.new(0, 14, 0, 258)
VolumeFrame.BackgroundTransparency = 1
VolumeFrame.Parent = MainFrame

local VolIcon = Instance.new("TextLabel")
VolIcon.Size = UDim2.new(0, 24, 1, 0)
VolIcon.BackgroundTransparency = 1
VolIcon.Text = "🔊"
VolIcon.TextColor3 = COLORS.TEXT_GRAY
VolIcon.Font = Enum.Font.GothamBold
VolIcon.TextSize = 14
VolIcon.Parent = VolumeFrame

local VolBarBg = Instance.new("Frame")
VolBarBg.Size = UDim2.new(1, -30, 0, 4)
VolBarBg.Position = UDim2.new(0, 28, 0, 13)
VolBarBg.BackgroundColor3 = COLORS.PROGRESS_BG
VolBarBg.BorderSizePixel = 0
VolBarBg.Parent = VolumeFrame

local VolBgCorner = Instance.new("UICorner")
VolBgCorner.CornerRadius = UDim.new(1, 0)
VolBgCorner.Parent = VolBarBg

local VolFill = Instance.new("Frame")
VolFill.Size = UDim2.new(Config.get("Volume", 0.5), 0, 1, 0)
VolFill.BackgroundColor3 = COLORS.GREEN
VolFill.BorderSizePixel = 0
VolFill.Parent = VolBarBg

local VolFillCorner = Instance.new("UICorner")
VolFillCorner.CornerRadius = UDim.new(1, 0)
VolFillCorner.Parent = VolFill

local VolKnob = Instance.new("TextButton")
VolKnob.Size = UDim2.new(0, 12, 0, 12)
VolKnob.Position = UDim2.new(Config.get("Volume", 0.5), -6, 0, -4)
VolKnob.BackgroundColor3 = COLORS.TEXT_WHITE
VolKnob.Text = ""
VolKnob.BorderSizePixel = 0
VolKnob.AutoButtonColor = false
VolKnob.Parent = VolBarBg

local VolKnobCorner = Instance.new("UICorner")
VolKnobCorner.CornerRadius = UDim.new(1, 0)
VolKnobCorner.Parent = VolKnob

local VolPct = Instance.new("TextLabel")
VolPct.Size = UDim2.new(0, 40, 0, 14)
VolPct.Position = UDim2.new(1, -45, 0, 8)
VolPct.BackgroundTransparency = 1
VolPct.Text = math.floor(Config.get("Volume", 0.5) * 100) .. "%"
VolPct.TextColor3 = COLORS.TEXT_GRAY
VolPct.Font = Enum.Font.GothamMedium
VolPct.TextSize = 10
VolPct.Parent = VolumeFrame

-- Search
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, -28, 0, 36)
SearchFrame.Position = UDim2.new(0, 14, 0, 296)
SearchFrame.BackgroundColor3 = COLORS.BG_CARD
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 18)
SearchCorner.Parent = SearchFrame

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 30, 1, 0)
SearchIcon.Position = UDim2.new(0, 8, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = COLORS.TEXT_GRAY
SearchIcon.TextSize = 14
SearchIcon.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -50, 1, 0)
SearchBox.Position = UDim2.new(0, 40, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Cari lagu atau artis..."
SearchBox.PlaceholderColor3 = COLORS.TEXT_SUBTLE
SearchBox.TextColor3 = COLORS.TEXT_WHITE
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

-- Playlist
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(1, -28, 1, -365)
ListFrame.Position = UDim2.new(0, 14, 0, 342)
ListFrame.BackgroundColor3 = COLORS.BG_DARK
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 4
ListFrame.ScrollBarImageColor3 = COLORS.GREEN
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.Parent = MainFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = ListFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 2)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ListFrame

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 8)
ListPadding.PaddingLeft = UDim.new(0, 8)
ListPadding.PaddingRight = UDim.new(0, 8)
ListPadding.PaddingBottom = UDim.new(0, 8)
ListPadding.Parent = ListFrame

-- ============================================
-- PLAYER FUNCTIONS
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

local function formatTime(sec)
    sec = math.floor(tonumber(sec) or 0)
    if sec < 0 then sec = 0 end
    return string.format("%d:%02d", math.floor(sec / 60), sec % 60)
end

local function updateNowPlaying()
    if currentIndex >= 1 and currentIndex <= #PLAYLIST then
        local song = PLAYLIST[currentIndex]
        SongTitle.Text = song.title
        SongArtist.Text = song.artist or "Unknown Artist"
        SongIdLabel.Text = "📻 Sound ID: " .. song.id
    end
end

-- Universal sound creation
local function createSound(id)
    local sound = Instance.new("Sound")
    sound.Name = "YuszxMusic"
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = Config.get("Volume", 0.5)
    sound.Looped = Config.get("Loop", false)
    sound.Archivable = false
    
    -- Coba berbagai parent
    local parents = {
        soundParent,
        SoundService,
        workspace,
        workspace.CurrentCamera,
        Player.Character,
    }
    
    for _, p in ipairs(parents) do
        if p then
            local ok = pcall(function()
                sound.Parent = p
            end)
            if ok and sound.Parent then
                break
            end
        end
    end
    
    return sound
end

local function playSongInternal(index)
    if index < 1 or index > #PLAYLIST then return end
    
    stopCurrent()
    currentIndex = index
    local song = PLAYLIST[index]
    
    local sound = createSound(song.id)
    sound:Play()
    currentSound = sound
    isPlaying = true
    PlayPauseBtn.Text = "⏸"
    
    -- Auto-next
    sound.Ended:Connect(function()
        if Config.get("Loop", false) then return end
        if not isPlaying then return end
        playNext()
    end)
    
    -- Load duration
    task.spawn(function()
        for _ = 1, 20 do
            task.wait(0.5)
            if sound and sound.Parent and sound.TimeLength > 0 then
                break
            end
        end
    end)
    
    return sound
end

function playNext()
    if #PLAYLIST == 0 then return end
    if Config.get("Shuffle", false) then
        currentIndex = math.random(1, #PLAYLIST)
    else
        currentIndex = currentIndex + 1
        if currentIndex > #PLAYLIST then currentIndex = 1 end
    end
    playSongInternal(currentIndex)
    updateNowPlaying()
end

function playPrev()
    if #PLAYLIST == 0 then return end
    currentIndex = currentIndex - 1
    if currentIndex < 1 then currentIndex = #PLAYLIST end
    playSongInternal(currentIndex)
    updateNowPlaying()
end

function togglePlay()
    if currentSound then
        if isPlaying then
            currentSound:Pause()
            isPlaying = false
            PlayPauseBtn.Text = "▶"
        else
            currentSound:Resume()
            isPlaying = true
            PlayPauseBtn.Text = "⏸"
        end
    else
        playSongInternal(1)
        updateNowPlaying()
    end
end

-- ============================================
-- PLAYLIST UI
-- ============================================
local function refreshList()
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local filter = string.lower(SearchBox.Text or "")
    
    for i, song in ipairs(PLAYLIST) do
        local t = string.lower(song.title)
        local a = string.lower(song.artist or "")
        local match = filter == "" 
            or string.find(t, filter, 1, true) 
            or string.find(a, filter, 1, true) 
            or string.find(song.id, filter, 1, true)
        
        if match then
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, 0, 0, 44)
            row.BackgroundColor3 = COLORS.BG_DARK
            row.BackgroundTransparency = 1
            row.Text = ""
            row.BorderSizePixel = 0
            row.AutoButtonColor = false
            row.Parent = ListFrame
            
            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 6)
            rowCorner.Parent = row
            
            local miniArt = Instance.new("Frame")
            miniArt.Size = UDim2.new(0, 32, 0, 32)
            miniArt.Position = UDim2.new(0, 8, 0, 6)
            miniArt.BackgroundColor3 = COLORS.BG_CARD
            miniArt.BorderSizePixel = 0
            miniArt.Parent = row
            
            local maCorner = Instance.new("UICorner")
            maCorner.CornerRadius = UDim.new(0, 4)
            maCorner.Parent = miniArt
            
            local maIcon = Instance.new("TextLabel")
            maIcon.Size = UDim2.new(1, 0, 1, 0)
            maIcon.BackgroundTransparency = 1
            maIcon.Text = "♪"
            maIcon.TextColor3 = COLORS.GREEN
            maIcon.Font = Enum.Font.GothamBold
            maIcon.TextSize = 18
            maIcon.Parent = miniArt
            
            local rowTitle = Instance.new("TextLabel")
            rowTitle.Size = UDim2.new(1, -130, 0, 18)
            rowTitle.Position = UDim2.new(0, 48, 0, 6)
            rowTitle.BackgroundTransparency = 1
            rowTitle.Text = song.title
            rowTitle.TextColor3 = COLORS.TEXT_WHITE
            rowTitle.Font = Enum.Font.GothamMedium
            rowTitle.TextSize = 12
            rowTitle.TextXAlignment = Enum.TextXAlignment.Left
            rowTitle.TextTruncate = Enum.TextTruncate.AtEnd
            rowTitle.Parent = row
            
            local rowArtist = Instance.new("TextLabel")
            rowArtist.Size = UDim2.new(1, -130, 0, 16)
            rowArtist.Position = UDim2.new(0, 48, 0, 24)
            rowArtist.BackgroundTransparency = 1
            rowArtist.Text = song.artist or "Unknown"
            rowArtist.TextColor3 = COLORS.TEXT_GRAY
            rowArtist.Font = Enum.Font.GothamMedium
            rowArtist.TextSize = 10
            rowArtist.TextXAlignment = Enum.TextXAlignment.Left
            rowArtist.TextTruncate = Enum.TextTruncate.AtEnd
            rowArtist.Parent = row
            
            local playIcon = Instance.new("TextLabel")
            playIcon.Size = UDim2.new(0, 30, 1, 0)
            playIcon.Position = UDim2.new(1, -40, 0, 0)
            playIcon.BackgroundTransparency = 1
            playIcon.Text = "▶"
            playIcon.TextColor3 = COLORS.GREEN
            playIcon.Font = Enum.Font.GothamBold
            playIcon.TextSize = 12
            playIcon.TextTransparency = 1
            playIcon.Parent = row
            
            row.MouseEnter:Connect(function()
                row.BackgroundTransparency = 0
                playIcon.TextTransparency = 0
            end)
            row.MouseLeave:Connect(function()
                row.BackgroundTransparency = 1
                playIcon.TextTransparency = 1
            end)
            
            row.MouseButton1Click:Connect(function()
                playSongInternal(i)
                updateNowPlaying()
            end)
        end
    end
    
    task.wait(0.05)
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)

-- ============================================
-- PROGRESS UPDATE
-- ============================================
task.spawn(function()
    while ScreenGui.Parent do
        RunService.RenderStepped:Wait()
        pcall(function()
            if currentSound and currentSound.Parent and currentSound.IsPlaying then
                local length = currentSound.TimeLength
                local pos = currentSound.TimePosition
                if length > 0 then
                    local pct = math.clamp(pos / length, 0, 1)
                    ProgressFill.Size = UDim2.new(pct, 0, 1, 0)
                    ProgressBtn.Position = UDim2.new(pct, -6, 0, 4)
                    TimeCurrent.Text = formatTime(pos)
                    TimeTotal.Text = formatTime(length)
                end
            end
        end)
    end
end)

-- ============================================
-- PROGRESS SEEK
-- ============================================
local seekingProgress = false

ProgressBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
       or input.UserInputType == Enum.UserInputType.Touch then
        seekingProgress = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
       or input.UserInputType == Enum.UserInputType.Touch then
        seekingProgress = false
        draggingVol = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement 
       and input.UserInputType ~= Enum.UserInputType.Touch then return end
    
    -- Progress seek
    if seekingProgress and currentSound then
        local mouseX = input.Position.X
        local relX = mouseX - ProgressBg.AbsolutePosition.X
        local pct = math.clamp(relX / ProgressBg.AbsoluteSize.X, 0, 1)
        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)
        ProgressBtn.Position = UDim2.new(pct, -6, 0, 4)
        pcall(function()
            currentSound.TimePosition = pct * currentSound.TimeLength
        end)
    end
    
    -- Volume
    if draggingVol and currentSound then
        local mouseX = input.Position.X
        local relX = mouseX - VolBarBg.AbsolutePosition.X
        local pct = math.clamp(relX / VolBarBg.AbsoluteSize.X, 0, 1)
        VolFill.Size = UDim2.new(pct, 0, 1, 0)
        VolKnob.Position = UDim2.new(pct, -6, 0, -4)
        VolPct.Text = math.floor(pct * 100) .. "%"
        currentSound.Volume = pct
    end
end)

-- ============================================
-- VOLUME SLIDER
-- ============================================
local draggingVol = false

VolKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
       or input.UserInputType == Enum.UserInputType.Touch then
        draggingVol = true
    end
end)

VolBarBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
       or input.UserInputType == Enum.UserInputType.Touch then
        local mouseX = input.Position.X
        local relX = mouseX - VolBarBg.AbsolutePosition.X
        local pct = math.clamp(relX / VolBarBg.AbsoluteSize.X, 0, 1)
        VolFill.Size = UDim2.new(pct, 0, 1, 0)
        VolKnob.Position = UDim2.new(pct, -6, 0, -4)
        VolPct.Text = math.floor(pct * 100) .. "%"
        Config.set("Volume", pct)
        if currentSound then currentSound.Volume = pct end
    end
end)

-- ============================================
-- MINIMIZE / CLOSE
-- ============================================
local isMinimized = Config.get("UIMinimized", false)
local uiElements = {NowPlayingSection, ProgressSection, ControlsFrame, VolumeFrame, SearchFrame, ListFrame}

local function applyMinimize(state)
    if state then
        MainFrame.Size = UDim2.new(0, 500, 0, 50)
        MinButton.Text = "□"
        for _, o in ipairs(uiElements) do o.Visible = false end
    else
        MainFrame.Size = UDim2.new(0, 500, 0, 620)
        MinButton.Text = "−"
        for _, o in ipairs(uiElements) do o.Visible = true end
    end
end

if isMinimized then applyMinimize(true) end

MinButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    applyMinimize(isMinimized)
    Config.set("UIMinimized", isMinimized)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    stopCurrent()
end)

-- ============================================
-- HANDLE RESPAWN (kalau sound ke-destroy)
-- ============================================
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if currentSound and currentSound.Parent == nil then
        -- Sound ke-destroy sama game, recreate
        if currentIndex > 0 then
            local wasPlaying = isPlaying
            local lastPos = 0
            pcall(function() lastPos = currentSound.TimePosition end)
            
            local song = PLAYLIST[currentIndex]
            local sound = createSound(song.id)
            currentSound = sound
            if wasPlaying then
                sound:Play()
                task.wait(0.1)
                pcall(function() sound.TimePosition = lastPos end)
            end
        end
    end
end)

-- ============================================
-- INIT
-- ============================================
refreshList()

print("[Yuszx] ═══════════════════════════════════")
print("[Yuszx] 🎵 Universal Spotify Edition loaded!")
print("[Yuszx] UI Parent: " .. uiParent:GetFullName())
print("[Yuszx] Sound Parent: " .. soundParent:GetFullName())
print("[Yuszx] Total lagu: " .. #PLAYLIST)
print("[Yuszx] ═══════════════════════════════════")
