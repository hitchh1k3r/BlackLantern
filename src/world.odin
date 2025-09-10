package main

import "shared"

Node :: struct {
  disabled : bool,
  name : string,
  sense_left_until_revealed : u8,
  pos : V3,
  right : V3,
  up : V3,
  size : f32,
  reveal : f32,
  senses : [SenseId]Sense,
  actions : []Action,
  center : bool,
  memory_fragment : bool,
}

SenseId :: enum {
  Contour,
  Smell,
  Feel,
  Listen,
  Taste,
  Poke,
}

Sense :: struct {
  response : string,
  used : bool,
  use_progress : f32,
}

Action :: struct {
  name : string,
  caption : string,
  used : bool,
  use_progress : f32,
  on_used : u8,
}

node_mem : [NodeId]Node
action_mem : [ActionId]Action

NodeSerial :: bit_field u32 {
  // byte 0
  sense_left_until_revealed : u8 | 3, // 0-7
  center : bool | 1,
  distance : u8 | 2,  // 1 2 4 16
  rotation : u8 | 2,  // -35 0 35 ??

  // byte 1
  yaw_pos : u8 | 5,   // 11.25 degrees apart
  pitch_pos : u8 | 3, // -40 -20 0 10 20 30 40 50

  // byte 2
  disabled : bool | 1,
  action_count : u8 | 2, // 0-3
  action1_callback : bool | 1,
  action2_callback : bool | 1,
  action3_callback : bool | 1,
  _ : u8 | 2,

  // byte 3
  sense_contour : bool | 1,
  sense_smell : bool | 1,
  sense_feel : bool | 1,
  sense_listen : bool | 1,
  sense_taste : bool | 1,
  sense_poke : bool | 1,
  _ : u8 | 2,
}

init_world :: proc "contextless" () {
  action_idx := 0
  callback_idx := u8(0)

  for serial, key in DATA_TEXTS {
    node : Node
    node.name = get_string()
    node.disabled = serial.disabled
    node.center = serial.center
    node.sense_left_until_revealed = serial.sense_left_until_revealed
    yaw := -f32(serial.yaw_pos) * 11.25 * RAD_PER_DEG
    pitch := (f32(serial.pitch_pos)-3) * 20 * RAD_PER_DEG
    if pitch > 0 {
      pitch /= 2
    }
    transform := mat4_yaw_pitch(yaw, 0)
    node.pos = (transform * V4{ 0, 2*pitch, -pow(3, f32(serial.distance)), 1 }).xyz
    transform *= mat4_yaw_pitch((f32(serial.rotation)-1) * 35 * RAD_PER_DEG, 0)
    node.right = (transform * V4{ 1, 0, 0, 0 }).xyz
    node.up = { 0, 1, 0 }
    node.size = 0.7
    node.actions = (transmute([^]Action)(&action_mem))[action_idx:action_idx+int(serial.action_count)]
    node_mem[key] = node

    if serial.sense_contour {
      node.senses[.Contour].response = get_string()
    }
    if serial.sense_smell {
      node.senses[.Smell].response = get_string()
    }
    if serial.sense_feel {
      node.senses[.Feel].response = get_string()
    }
    if serial.sense_listen {
      node.senses[.Listen].response = get_string()
    }
    if serial.sense_taste {
      node.senses[.Taste].response = get_string()
    }
    if serial.sense_poke {
      node.senses[.Poke].response = get_string()
    }

    for i in 0..<serial.action_count {
      action : Action
      action.name = get_string()
      action.caption = get_string()
      if (i == 0 && serial.action1_callback) ||
         (i == 1 && serial.action2_callback) ||
         (i == 2 && serial.action3_callback) {
        callback_idx += 1
        action.on_used = callback_idx
      }
      action_mem[ActionId(action_idx)] = action
      action_idx += 1
    }
  }
}

get_string :: proc "contextless" () -> (result : string) {
  last_can_break := false
  for r, i in DATA_STRING {
    if r == '\x00' {
      result = DATA_STRING[:i]
      DATA_STRING = DATA_STRING[i+1:]
      return
    }
    if last_can_break && r >= 'A' && r <= 'Z' {
      result = DATA_STRING[:i]
      DATA_STRING = DATA_STRING[i:]
      return
    }
    last_can_break = (r >= 'a' && r <= 'z') || r == '.' || r == '!'
  }

  result = DATA_STRING
  return
}

////////////////////

LocationId :: enum {
  Dream3_House,
  Memory1,
  ChildsRoom_Floor,
  Memory2,
  Dream3_Outside,
  Credits,
  Memory3,
}

NodeId :: enum {
  Dream3_House_Table,
  Dream3_House_Chair,
  Dream3_House_Window,
  Dream3_House_Door,
  Dream3_House_Outside,
  Memory1_Bounce,
  Memory1_Laugh,
  Memory1_Touch,
  Memory1_Home,
  ChildsRoom_Floor_Bed,
  Memory2_Lamp,
  Memory2_Light,
  Memory2_Flash,
  Memory2_Dark,
  Memory2_Listen,
  Dream3_Outside_Insignificance,
  Dream3_Outside_Unfinishedness,
  Dream3_Outside_Erasure,
  Dream3_Outside_Tree,
  Dream3_Outside_Street,
  Dream3_Outside_Moon,
  Dream3_Outside_Spoon,
  Dream3_Outside_Slide,
  Dream3_Outside_Ball,
  Dream3_Outside_Bed,
  Credits_A_Game_Made,
  Credits_Thanks_For_Playing,
  Memory3_Stir,
  Memory3_Voice,
  Memory3_Siren,
  Memory3_Ache,
}

ActionId :: enum {
  Dream3_House_Table_Climb,
  Dream3_House_Chair_Scratch,
  Dream3_House_Window_Look,
  Dream3_House_Door_Push,
  Dream3_House_Outside_Walk_Outside,
  Memory1_Bounce_Remember,
  Memory1_Laugh_Remember,
  Memory1_Touch_Remember,
  Memory1_Home_Remember,
  ChildsRoom_Floor_Bed_Sleep,
  Memory2_Lamp_Remember,
  Memory2_Light_Remember,
  Memory2_Flash_Remember,
  Memory2_Dark_Remember,
  Memory2_Listen_Remember,
  Dream3_Outside_Tree_Scratch,
  Dream3_Outside_Street_Listen,
  Dream3_Outside_Moon_Call_Out,
  Dream3_Outside_Spoon_Stir,
  Dream3_Outside_Slide_Project,
  Dream3_Outside_Ball_Throw,
  Dream3_Outside_Bed_Rest,
  Credits_A_Game_Made_By_Hitchh1k3r,
  Credits_A_Game_Made_In_13_Kibibytes,
  Credits_A_Game_Made_For_Js13k_2025,
  Memory3_Stir_Remember,
  Memory3_Voice_Remember,
  Memory3_Siren_Remember,
  Memory3_Ache_Remember,
}

load_location :: proc "contextless" (location : LocationId) {
  shared.mem.lights = {}
  switch location {
    case .Dream3_House:

      nodes = (transmute([^]Node)(&node_mem))[0:5]

    case .Memory1:

      shared.mem.lights[0].dir = { 0, 1, 0 }
      shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[0].spread = 0.5
      shared.mem.lights[0].brightness = 0.9
      shared.mem.lights[1].dir = { 0, -1, 0 }
      shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[1].spread = 0.5
      shared.mem.lights[1].brightness = 0.9
    
      nodes = (transmute([^]Node)(&node_mem))[5:9]

    case .ChildsRoom_Floor:

        shared.mem.lights[0].dir = { 0, 0, -1 }
        shared.mem.lights[0].color = 0.25*{ 0.9, 0.9, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
      
      nodes = (transmute([^]Node)(&node_mem))[9:10]

    case .Memory2:

      shared.mem.lights[0].dir = { 0, 1, 0 }
      shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[0].spread = 0.5
      shared.mem.lights[0].brightness = 0.9
      shared.mem.lights[1].dir = { 0, -1, 0 }
      shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[1].spread = 0.5
      shared.mem.lights[1].brightness = 0.9
      shared.mem.lights[2].dir = { 0.981, 0.196, 0 }
      shared.mem.lights[2].color = 0
      shared.mem.lights[2].spread = 0.5
      shared.mem.lights[2].brightness = 0.5
    
      nodes = (transmute([^]Node)(&node_mem))[10:15]

    case .Dream3_Outside:

      nodes = (transmute([^]Node)(&node_mem))[15:25]

    case .Credits:

      nodes = (transmute([^]Node)(&node_mem))[25:27]

    case .Memory3:

      shared.mem.lights[0].dir = { 0, 1, 0 }
      shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[0].spread = 0.5
      shared.mem.lights[0].brightness = 0.9
      shared.mem.lights[1].dir = { 0, -1, 0 }
      shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[1].spread = 0.5
      shared.mem.lights[1].brightness = 0.9
    
      nodes = (transmute([^]Node)(&node_mem))[27:31]

  }
}

DATA_STRING := "TableClimbThe higher you climb, the taller the table gets.ChairScratchThe chair becomes a pile of splinters.WindowLookThere is only darkness outside.DoorPushThe door turns to ash at your touch.OutsideWalk Outside\x00\x00BounceRememberThe child tosses the ball across the floor.\nYou spring after it, paws clumsy, heart quick.LaughRememberHigh, bright sounds fill the room. The child\nclapping as you press the ball with your nose.TouchRememberSmall fingers press into your fur.\nWarmth, gentle and proud.HomeRememberThis is your home: the floor,\nthe ball, the child's eyes on you.Bed\x00self\x00soft\x00squishSleepYou are too lonely to sleep right now.LampRememberThe father clicks on the lamp.\nDust dances in the beam.LightRememberThe slides glow, projected onto the wall.\nShapes and faces; your families frozen smiles.FlashRememberAt the window: a brilliance greater than\nthe projection, greater than the sun.\nIt consumed everything, sight burned away.DarkRememberThe lamp off, the light faded, the picture\nvanished. The images remain only in memory.ListenRememberWithout vision: sound is your guide.\nEars are now your eyes.InsignificanceUnfinishednessErasureTreeScratchI claw deep into the bark, but my marks do\nnot last, the tree has already forgotten me.StreetListenI listen, not for others, but for the\nmissing chapter of myself...MoonCall OutI raise my voice to the moon, and it\nanswers: nothing has ever known you.SpoonStirA single act of care ripples outward,\nuntil Insignificance drowns in its waves.SlideProjectErasure burns away in the projected light,\neach copy reigniting the lamp.BallThrowWith no start nor end, a circle defies\nUnfinishedness; the cycle of play\ncompletes itself.BedRest\x00\x00A Game Made...By Hitchh1k3r\x00\x00In 13 Kibibytes\x00\x00For JS13K 2025\x00\x00Thanks\nFor\nPlaying!StirRememberThe spoon circles in the pot. The air\nfills with scents of comfort and love.VoiceRememberThe mother hums,\nher tune wraps around the kitchen.SirenRememberThe song ends in a sudden wail.\nNot a song nor wind, but a warning.\nThey drop everything and run.AcheRememberWhite fire swallows the sky, your chest\ntightens, steps grow heavier.\nYour body gives less with each dawn."

DATA_TEXTS := [NodeId]NodeSerial{
  .Dream3_House_Table = auto_cast 702736,
  .Dream3_House_Chair = auto_cast 694864,
  .Dream3_House_Window = auto_cast 180576,
  .Dream3_House_Door = auto_cast 698000,
  .Dream3_House_Outside = auto_cast 763488,
  .Memory1_Bounce = auto_cast 172120,
  .Memory1_Laugh = auto_cast 174168,
  .Memory1_Touch = auto_cast 176216,
  .Memory1_Home = auto_cast 702555,
  .ChildsRoom_Floor_Bed = auto_cast 637689155,
  .Memory2_Lamp = auto_cast 696408,
  .Memory2_Light = auto_cast 173656,
  .Memory2_Flash = auto_cast 699736,
  .Memory2_Dark = auto_cast 701272,
  .Memory2_Listen = auto_cast 703068,
  .Dream3_Outside_Insignificance = auto_cast 114808,
  .Dream3_Outside_Unfinishedness = auto_cast 117624,
  .Dream3_Outside_Erasure = auto_cast 120184,
  .Dream3_Outside_Tree = auto_cast 697680,
  .Dream3_Outside_Street = auto_cast 695136,
  .Dream3_Outside_Moon = auto_cast 716912,
  .Dream3_Outside_Spoon = auto_cast 213058,
  .Dream3_Outside_Slide = auto_cast 218434,
  .Dream3_Outside_Ball = auto_cast 215874,
  .Dream3_Outside_Bed = auto_cast 725059,
  .Credits_A_Game_Made = auto_cast 441424,
  .Credits_Thanks_For_Playing = auto_cast 42072,
  .Memory3_Stir = auto_cast 172120,
  .Memory3_Voice = auto_cast 174168,
  .Memory3_Siren = auto_cast 692312,
  .Memory3_Ache = auto_cast 694363,
}

action_callback :: proc "contextless" (idx : u8) {
  switch idx {
  case 1:
                node_mem[.Dream3_House_Table].pos.y *= 1.2
                action_mem[.Dream3_House_Table_Climb].used = false
  case 2:
                node_mem[.Dream3_House_Chair].disabled = true
  case 3:
                node_mem[.Dream3_House_Door].disabled = true
                node_mem[.Dream3_House_Outside].disabled = false
  case 4:
                load_location(.Dream3_Outside)
  case 5:
              load_location(.Memory2)
  case 6:
              shared.mem.lights[2].color = 0.9*{ 1, 1, 0 }
  case 7:
              shared.mem.lights[0].color = { 1, 1, 1 }
              shared.mem.lights[0].spread = 1.0
              shared.mem.lights[1] = {}
  case 8:
              shared.mem.lights[0].color = 0
              shared.mem.lights[1] = {}
              shared.mem.lights[2].color = 0
  case 9:
              load_location(.Memory3)
  case 10:
                node_mem[.Dream3_Outside_Tree].disabled = true
                node_mem[.Dream3_Outside_Erasure].disabled = false
                node_mem[.Dream3_Outside_Slide].disabled = false
                node_mem[.Dream3_Outside_Ball].sense_left_until_revealed -= 1
                node_mem[.Dream3_Outside_Spoon].sense_left_until_revealed -= 1
  case 11:
                node_mem[.Dream3_Outside_Street].disabled = true
                node_mem[.Dream3_Outside_Unfinishedness].disabled = false
                node_mem[.Dream3_Outside_Ball].disabled = false
                node_mem[.Dream3_Outside_Slide].sense_left_until_revealed -= 1
                node_mem[.Dream3_Outside_Spoon].sense_left_until_revealed -= 1
  case 12:
                /*
                  play_sound({ 0, 0.0115606058, 0.023121212, 0.034681819, 0.046242423, 0.057803027, 0.069363639, 0.08092424, 0.092484847, 0.10404545, 0.115606055, 0.127166659, 0.138727278, 0.15028788, 0.16184849, 0.173409089, 0.18496969, 0.1965303, 0.2080909, 0.2196515, 0.231212109, 0.242772728, 0.25433332, 0.26589394, 0.27745456, 0.28901514, 0.30057576, 0.31213635, 0.32369697, 0.33525756, 0.34681818, 0.35837877, 0.36993939, 0.3815, 0.39306059, 0.4046212, 0.4161818, 0.42774242, 0.439303, 0.45086363, 0.46242422, 0.47398484, 0.48554546, 0.49710605, 0.50866663, 0.52022725, 0.53178787, 0.54334849, 0.5549091, 0.56646967, 0.57803029, 0.5895909, 0.6011515, 0.61271209, 0.6242727, 0.6358333, 0.64739394, 0.65895456, 0.6705151, 0.68207574, 0.69363636, 0.70519698, 0.71675754, 0.72831815, 0.73987877, 0.75143939 },
                             { 893.5791, 890.38776, 890.38776, 896.7705, 906.34454, 919.10999, 931.87537, 944.6408, 960.5976, 966.98029, 970.17163, 973.36298, 979.74567, 989.31976, 998.8938, 1002.08514, 989.31976, 979.74567, 976.5543, 976.5543, 973.36298, 960.5976, 947.83215, 935.0667, 925.49268, 925.49268, 925.49268, 903.1532, 896.7705, 890.38776, 884.00507, 880.8137, 877.62238, 874.431, 871.2396, 871.2396, 871.2396, 864.85693, 858.47424, 848.90015, 839.3261, 836.13477, 829.75208, 823.3693, 820.17798, 813.79529, 807.4126, 801.02985, 797.8385, 797.8385, 794.64716, 791.4558, 788.26447, 788.26447, 788.26447, 781.8817, 775.499, 778.69037, 785.0731, 781.8817, 765.92499, 756.35089, 746.77686, 737.20276, 730.82007, 724.43738,
                               1793.541, 1783.9669, 1783.9669, 1796.7323, 1819.07178, 1838.21997, 1866.9421, 1892.4729, 1918.00378, 1933.96057, 1940.34326, 1946.726, 1956.3, 1975.4481, 1997.7876, 2004.17029, 1981.8308, 1965.8741, 1956.3, 1956.3, 1949.9174, 1927.57788, 1898.85559, 1873.3248, 1854.1766, 1850.9854, 1850.9854, 1806.3064, 1793.541, 1783.9669, 1768.0101, 1764.8187, 1761.6274, 1752.0533, 1748.862, 1745.6707, 1742.4792, 1736.0966, 1720.13977, 1700.9917, 1681.8436, 1669.0781, 1659.5042, 1649.93, 1640.356, 1630.7819, 1618.01648, 1608.44238, 1602.05969, 1595.677, 1589.2943, 1582.9116, 1582.9116, 1579.7202, 1576.5289, 1566.9548, 1557.3807, 1563.7634, 1573.3375, 1563.7634, 1535.0413, 1509.5105, 1496.745, 1474.4055, 1461.6401, 1461.6401,
                               2671.1633, 2671.1633, 2671.1633, 2696.694, 2725.4163, 2754.1384, 2802.0088, 2837.1138, 2881.7927, 2904.132, 2913.7063, 2923.2803, 2939.237, 2971.1506, 2999.8728, 3006.2556, 2974.342, 2948.811, 2936.0457, 2936.0457, 2926.4717, 2894.558, 2853.0706, 2814.7742, 2782.8608, 2782.8608, 2786.052, 2802.0088, 2690.3115, 2677.5461, 2658.3979, 2648.8237, 2645.6326, 2636.0583, 2626.4844, 2623.293, 2620.1016, 2604.1448, 2581.8054, 2553.0833, 2527.5525, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043, 2508.4043,
                               3567.9338, 3567.9338, 3567.9338, 3593.4646, 3634.9521, 3670.0571, 3730.6929, 3772.1804, 3832.8162, 3874.3037, 3887.0693, 3896.6433, 3915.7915, 3957.279, 4001.958, 4011.532, 3970.0444, 3931.7483, 3912.6, 3915.7915, 3899.8347, 3861.5383, 3810.4768, 3753.0322, 3711.5447, 3708.3533, 3711.5447, 3753.0322, 3587.082, 3571.1252, 3542.403, 3532.8289, 3526.4463, 3513.6809, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153, 3500.9153,
                               4659.377, 4659.377, 4659.377, 4659.377, 4659.377, 4659.377, 4659.377, 4720.0127, 4793.4136, 4841.284, 4860.432, 4873.1978, 4895.537, 4933.8335, 4997.6606, 5016.8086, 4972.1294, 4921.0679, 4892.3457, 4892.3457, 4882.7715, 4838.0928, 4777.457, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, 4700.8643, },
                             { 0.037967477, 0.06352449, 0.06352449, 0.06526885, 0.06526885, 0.06526885, 0.067061089, 0.06797557, 0.068902545, 0.06984216, 0.06984216, 0.071759999, 0.072738558, 0.07473593, 0.07678815, 0.07575509, 0.07575509, 0.07575509, 0.07473593, 0.072738558, 0.071759999, 0.071759999, 0.071759999, 0.071759999, 0.072738558, 0.071759999, 0.071759999, 0.068902545, 0.068902545, 0.06984216, 0.06984216, 0.071759999, 0.072738558, 0.071759999, 0.07079458, 0.06797557, 0.06526885, 0.06352449, 0.06439076, 0.067061089, 0.07079458, 0.073730476, 0.073730476, 0.073730476, 0.07473593, 0.07575509, 0.07678815, 0.073730476, 0.072738558, 0.072738558, 0.07473593, 0.07473593, 0.07575509, 0.07473593, 0.073730476, 0.07473593, 0.077835277, 0.07678815, 0.071759999, 0.06352449, 0.057778299, 0.055477593, 0.053268515, 0.04845004, 0.044668358, 0.031409346,
                               0.035004, 0.07678815, 0.07678815, 0.07079458, 0.068902545, 0.068902545, 0.06984216, 0.07575509, 0.083289117, 0.094086967, 0.104854777, 0.12006372, 0.13022844, 0.135629117, 0.13380446, 0.13022844, 0.13200434, 0.13380446, 0.13200434, 0.12504286, 0.118448459, 0.112201847, 0.104854777, 0.094086967, 0.087926067, 0.08442489, 0.08106317, 0.071759999, 0.07575509, 0.082168594, 0.0799726, 0.07575509, 0.07473593, 0.068902545, 0.06266987, 0.057778299, 0.053994928, 0.053268515, 0.052551888, 0.053994928, 0.054731235, 0.056234132, 0.053994928, 0.054731235, 0.054731235, 0.052551888, 0.052551888, 0.053994928, 0.052551888, 0.04845004, 0.04845004, 0.050459296, 0.051844887, 0.053268515, 0.053994928, 0.055477593, 0.057000987, 0.056234132, 0.054731235, 0.049780462, 0.041181855, 0.033157997, 0.030986782, 0.024282545, 0.015321248, 0.001,
                               0.001, 0.01595663, 0.01595663, 0.019817954, 0.02300195, 0.026338331, 0.027804673, 0.02975291, 0.032271832, 0.036952779, 0.042312697, 0.046520796, 0.04845004, 0.049780462, 0.051844887, 0.053268515, 0.051844887, 0.055477593, 0.055477593, 0.055477593, 0.055477593, 0.055477593, 0.051844887, 0.047155179, 0.041181855, 0.039542023, 0.037967477, 0.02975291, 0.022387212, 0.022086035, 0.020921284, 0.020088203, 0.019028813, 0.017307535, 0.016394788, 0.016618365, 0.017307535, 0.017782794, 0.01802529, 0.01754356, 0.015530177, 0.015115121, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001,
                               0.001, 0.02300195, 0.02300195, 0.032711908, 0.038485233, 0.045894932, 0.047798224, 0.050459296, 0.04845004, 0.047798224, 0.045894932, 0.046520796, 0.04527749, 0.042312697, 0.041181855, 0.04008125, 0.041181855, 0.047155179, 0.047798224, 0.04845004, 0.047155179, 0.046520796, 0.046520796, 0.045894932, 0.043474574, 0.040627822, 0.038485233, 0.030158646, 0.027804673, 0.028183833, 0.025634427, 0.02300195, 0.022086035, 0.018271104, 0.015741965, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001,
                               0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.015115121, 0.019817954, 0.022692498, 0.02975291, 0.030986782, 0.030569905, 0.030158646, 0.030569905, 0.028183833, 0.02331563, 0.02300195, 0.028957741, 0.028183833, 0.027804673, 0.028183833, 0.024613675, 0.021495763, 0.016618365, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001 })
                */
                node_mem[.Dream3_Outside_Moon].disabled = true
                node_mem[.Dream3_Outside_Insignificance].disabled = false
                node_mem[.Dream3_Outside_Spoon].disabled = false
                node_mem[.Dream3_Outside_Slide].sense_left_until_revealed -= 1
                node_mem[.Dream3_Outside_Ball].sense_left_until_revealed -= 1
  case 13:
                load_location(.Credits)
  case 14:
              play_sound({ 0.0, 6.708, 13.125, 18.933 }, { 402, 430, 430, 402, 402, 818, 818, 402, 402, 1248, 1248, 402, 402, 1687, 1687, 402, 402, 2099, 2099, 402, 402, 2455, 2455, 402 }, { 0.001, 0.1, 0.1, 0.001, 0.001, 0.2, 0.2, 0.001, 0.001, 0.05, 0.05, 0.001, 0.001, 0.065, 0.065, 0.001, 0.001, 0.04, 0.04, 0.001, 0.001, 0.02, 0.02, 0.001 })
  case 15:
              load_location(.Dream3_House)
                }
}