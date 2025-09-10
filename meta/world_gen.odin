#+feature dynamic-literals
package world_gen

import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"
import "core:unicode"

NameSpace :: union {
  NS,
  Location,
}
NS :: map[string]NameSpace
Location :: struct {
  setup : string,
  texts : []Text
}
Text :: struct {
  key : string,
  name : string,
  disabled : bool,
  centered : bool,
  memory : bool,
  // origin relative position:
  yaw : int, // 0 = north, 8 = west
  pitch : int, // 0 = flat, -3 = -30 degrees,  [-3..4]
  distance : enum { D1, D3, D9, D27 }, // most things are 3 units away (D3)
  rotation : enum { Left, Center, Right }, // faces the origin, and optionally turned 35 degrees to a side
  sense_required : int,
  sense_contour : string,
  sense_smell : string,
  sense_feel : string,
  sense_listen : string,
  sense_taste : string,
  sense_poke : string,
  actions : []Action,
}
Action :: struct {
  key : string,
  name : string,
  caption : string,
  on_use : string,
}

world := NS{
  "ChildsRoom" = NS{
    "Floor" = Location{
      setup = `
        shared.mem.lights[0].dir = { 0, 0, -1 }
        shared.mem.lights[0].color = 0.25*{ 0.9, 0.9, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
      `,
      texts = {
        {
          name = "Bed",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -3,
          pitch = -1,
          distance = .D1,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "",
          sense_smell = "self",
          sense_feel = "soft",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "squish",
          actions = {
            {
              name = "Sleep",
              caption = "You are too lonely to sleep right now.",
              on_use = ``,
            }
          },
        },
      },
    },
  },
  "Memory1" = Location{
    setup = `
      shared.mem.lights[0].dir = { 0, 1, 0 }
      shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[0].spread = 0.5
      shared.mem.lights[0].brightness = 0.9
      shared.mem.lights[1].dir = { 0, -1, 0 }
      shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[1].spread = 0.5
      shared.mem.lights[1].brightness = 0.9
    `,
    texts = {
      {
        name = "Bounce",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 0,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The child tosses the ball across the floor.\n" +
                      "You spring after it, paws clumsy, heart quick.",
            on_use = ``,
          }
        },
      },
      {
        name = "Laugh",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 8,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "High, bright sounds fill the room. The child\n" +
                      "clapping as you press the ball with your nose.",
            on_use = ``,
          }
        },
      },
      {
        name = "Touch",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 16,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "Small fingers press into your fur.\n" +
                      "Warmth, gentle and proud.",
            on_use = ``,
          }
        },
      },
      {
        name = "Home",
        disabled = false,
        centered = true,
        memory = false, // exit memory
        yaw = -8,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 3,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "This is your home: the floor,\n" +
                      "the ball, the child's eyes on you.",
            on_use = `
              load_location(.Memory2)
              `,
          }
        },
      },
    },
  },
  "Memory2" = Location{
    setup = `
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
    `,
    texts = {
      {
        name = "Lamp",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 0,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The father clicks on the lamp.\n"+
                      "Dust dances in the beam.",
            on_use = `
              shared.mem.lights[2].color = 0.9*{ 1, 1, 0 }
              `,
          }
        },
      },
      {
        name = "Light",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 6,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The slides glow, projected onto the wall.\n"+
                      "Shapes and faces; your families frozen smiles.",
            on_use = ``,
          }
        },
      },
      {
        name = "Flash",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 13,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "At the window: a brilliance greater than\n"+
                      "the projection, greater than the sun.\n"+
                      "It consumed everything, sight burned away.",
            on_use = `
              shared.mem.lights[0].color = { 1, 1, 1 }
              shared.mem.lights[0].spread = 1.0
              shared.mem.lights[1] = {}
              `,
          }
        },
      },
      {
        name = "Dark",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 19,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The lamp off, the light faded, the picture\n"+
                      "vanished. The images remain only in memory.",
            on_use = `
              shared.mem.lights[0].color = 0
              shared.mem.lights[1] = {}
              shared.mem.lights[2].color = 0
              `,
          }
        },
      },
      {
        name = "Listen",
        disabled = false,
        centered = true,
        memory = false, // exit memory
        yaw = 26,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 4,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "Without vision: sound is your guide.\n"+
                      "Ears are now your eyes.",
            on_use = `
              load_location(.Memory3)
              `,
          }
        },
      },
    },
  },
  "Memory3" = Location{
    setup = `
      shared.mem.lights[0].dir = { 0, 1, 0 }
      shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[0].spread = 0.5
      shared.mem.lights[0].brightness = 0.9
      shared.mem.lights[1].dir = { 0, -1, 0 }
      shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
      shared.mem.lights[1].spread = 0.5
      shared.mem.lights[1].brightness = 0.9
    `,
    texts = {
      {
        name = "Stir",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 0,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The spoon circles in the pot. The air\n"+
                      "fills with scents of comfort and love.",
            on_use = ``,
          }
        },
      },
      {
        name = "Voice",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 8,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The mother hums,\n"+
                      "her tune wraps around the kitchen.",
            on_use = ``,
          }
        },
      },
      {
        name = "Siren",
        disabled = false,
        centered = true,
        memory = true,
        yaw = 16,
        pitch = 1,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "The song ends in a sudden wail.\n"+
                      "Not a song nor wind, but a warning.\n"+
                      "They drop everything and run.",
            on_use = `
              play_sound({ 0.0, 6.708, 13.125, 18.933 }, { 402, 430, 430, 402, 402, 818, 818, 402, 402, 1248, 1248, 402, 402, 1687, 1687, 402, 402, 2099, 2099, 402, 402, 2455, 2455, 402 }, { 0.001, 0.1, 0.1, 0.001, 0.001, 0.2, 0.2, 0.001, 0.001, 0.05, 0.05, 0.001, 0.001, 0.065, 0.065, 0.001, 0.001, 0.04, 0.04, 0.001, 0.001, 0.02, 0.02, 0.001 })
              `,
          }
        },
      },
      {
        name = "Ache",
        disabled = false,
        centered = true,
        memory = false, // exit memory
        yaw = -8,
        pitch = 1,
        distance = .D3,
        rotation = .Center,
        sense_required = 3,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "Remember",
            caption = "White fire swallows the sky, your chest\n"+
                      "tightens, steps grow heavier.\n"+
                      "Your body gives less with each dawn.",
            on_use = `
              load_location(.Dream3_House)
              `,
          }
        },
      },
    },
  },
  "Dream3" = NS{
    "House" = Location{
      setup = ``,
      texts = {
        {
          name = "Table",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -7,
          pitch = 2,
          distance = .D3,
          rotation = .Left,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Climb",
              caption = "The higher you climb, the taller the table gets.",
              on_use = `
                node_mem[.Dream3_House_Table].pos.y *= 1.2
                action_mem[.Dream3_House_Table_Climb].used = false
                `,
            }
          },
        },
        {
          name = "Chair",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -6,
          pitch = 1,
          distance = .D3,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Scratch",
              caption = "The chair becomes a pile of splinters.",
              on_use = `
                node_mem[.Dream3_House_Chair].disabled = true
                `,
            }
          },
        },
        {
          name = "Window",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 1,
          pitch = 3,
          distance = .D9,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Look",
              caption = "There is only darkness outside.",
              on_use = ``,
            }
          },
        },
        {
          name = "Door",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 6,
          pitch = 2,
          distance = .D3,
          rotation = .Right,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Push",
              caption = "The door turns to ash at your touch.",
              on_use = `
                node_mem[.Dream3_House_Door].disabled = true
                `,
            }
          },
        },
        {
          name = "Outside",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 6,
          pitch = 2,
          distance = .D9,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Walk Outside",
              caption = "", // NOCOMMIT
              on_use = `
                load_location(.Dream3_Outside)
                `,
            }
          },
        },
      },
    },
    "Outside" = Location{
      setup = ``,
      texts = {
        {
          name = "Insignificance",
          disabled = true,
          centered = true,
          memory = false,
          yaw = 0,
          pitch = 3,
          distance = .D27,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {},
        },
        {
          name = "Unfinishedness",
          disabled = true,
          centered = true,
          memory = false,
          yaw = 11,
          pitch = 3,
          distance = .D27,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {},
        },
        {
          name = "Erasure",
          disabled = true,
          centered = true,
          memory = false,
          yaw = -11,
          pitch = 3,
          distance = .D27,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {},
        },
        {
          name = "Tree",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 5,
          pitch = 2,
          distance = .D3,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Scratch",
              caption = "I claw deep into the bark, but my marks do\n"+
                        "not last, the tree has already forgotten me.",
              on_use = `
                node_mem[.Dream3_Outside_Tree].disabled = true
                node_mem[.Dream3_Outside_Erasure].disabled = false
                node_mem[.Dream3_Outside_Slide].disabled = false
                node_mem[.Dream3_Outside_Ball].sense_left_until_revealed -= 1
                node_mem[.Dream3_Outside_Spoon].sense_left_until_revealed -= 1
                `,
            }
          },
        },
        {
          name = "Street",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -5,
          pitch = 1,
          distance = .D9,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Listen",
              caption = "I listen, not for others, but for the\n"+
                        "missing chapter of myself...",
              on_use = `
                node_mem[.Dream3_Outside_Street].disabled = true
                node_mem[.Dream3_Outside_Unfinishedness].disabled = false
                node_mem[.Dream3_Outside_Ball].disabled = false
                node_mem[.Dream3_Outside_Slide].sense_left_until_revealed -= 1
                node_mem[.Dream3_Outside_Spoon].sense_left_until_revealed -= 1
                `,
            }
          },
        },
        {
          name = "Moon",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 16,
          pitch = 4,
          distance = .D27,
          rotation = .Center,
          sense_required = 0,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Call Out",
              caption = "I raise my voice to the moon, and it\n"+
                        "answers: nothing has ever known you.",
              on_use = `
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
                `,
            }
          },
        },
        {
          name = "Spoon",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 0,
          pitch = -1,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Stir",
              caption = "A single act of care ripples outward,\n"+
                        "until Insignificance drowns in its waves.",
              on_use = ``,
            }
          },
        },
        {
          name = "Slide",
          disabled = true,
          centered = false,
          memory = false,
          yaw = -11,
          pitch = -1,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Project",
              caption = "Erasure burns away in the projected light,\n"+
                        "each copy reigniting the lamp.",
              on_use = ``,
            }
          },
        },
        {
          name = "Ball",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 11,
          pitch = -1,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Throw",
              caption = "With no start nor end, a circle defies\n"+
                        "Unfinishedness; the cycle of play\n"+
                        "completes itself.",
              on_use = ``,
            }
          },
        },
        {
          name = "Bed",
          disabled = true,
          centered = false,
          memory = false, // exit memory
          yaw = 16,
          pitch = -3,
          distance = .D1,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Rest",
              caption = "", // NOCOMMIT
              on_use = `
                load_location(.Credits)
                `,
            }
          },
        },
      },
    },
  },
  "Credits" = Location{
    setup = ``,
    texts = {
      {
        name = "A Game Made...",
        disabled = false,
        centered = false,
        memory = false,
        yaw = -4,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {
          {
            name = "By Hitchh1k3r",
            caption = "",
            on_use = ``,
          },
          {
            name = "In 13 Kibibytes",
            caption = "",
            on_use = ``,
          },
          {
            name = "For JS13K 2025",
            caption = "",
            on_use = ``,
          },
        },
      },
      {
        name = "Thanks\nFor\nPlaying!",
        disabled = false,
        centered = true,
        memory = false,
        yaw = 4,
        pitch = 2,
        distance = .D3,
        rotation = .Center,
        sense_required = 0,
        sense_contour = "",
        sense_smell = "",
        sense_feel = "",
        sense_listen = "",
        sense_taste = "",
        sense_poke = "",
        actions = {},
      },
    },
  },
}



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

main :: proc() {
  string_pool : strings.Builder
  strings.builder_init(&string_pool, 0, 4096)

  locations : map[string]Location
  process_ns("", world, &locations)
  process_ns :: proc(prefix : string, ns : NS, locations : ^map[string]Location) {
    for key, ns in ns {
      prefix := prefix
      if prefix != "" {
        prefix = fmt.tprintf("%v_%v", prefix, key)
      } else {
        prefix = key
      }
      switch ns in ns {
        case NS:
          process_ns(prefix, ns, locations)
        case Location:
          locations[prefix] = ns
      }
    }
  }

  texts : [dynamic]Text
  actions : [dynamic]Action
  fmt.print("LocationId :: enum {\n")
  for name, location in locations {
    fmt.printf("  %v,\n", name)
    for text in location.texts {
      text := text
      text.key = fmt.tprintf("%v_%v", name, to_key(text.name))
      append(&texts, text)
      add_string(&string_pool, text.name)
      if text.sense_contour != "" {
        add_string(&string_pool, text.sense_contour)
      }
      if text.sense_smell != "" {
        add_string(&string_pool, text.sense_smell)
      }
      if text.sense_feel != "" {
        add_string(&string_pool, text.sense_feel)
      }
      if text.sense_listen != "" {
        add_string(&string_pool, text.sense_listen)
      }
      if text.sense_taste != "" {
        add_string(&string_pool, text.sense_taste)
      }
      if text.sense_poke != "" {
        add_string(&string_pool, text.sense_poke)
      }
      for action in text.actions {
        action := action
        action.key = fmt.tprintf("%v_%v", text.key, to_key(action.name))
        append(&actions, action)
        add_string(&string_pool, action.name)
        add_string(&string_pool, action.caption)
      }
    }
  }
  fmt.print("}\n\n")

  fmt.print("NodeId :: enum {\n")
  for text in texts {
    fmt.printf("  %v,\n", text.key)
  }
  fmt.print("}\n\n")

  fmt.print("ActionId :: enum {\n")
  for action in actions {
    fmt.printf("  %v,\n", action.key)
  }
  fmt.print("}\n\n")

  fmt.print("load_location :: proc \"contextless\" (location : LocationId) {\n")
  fmt.print("  shared.mem.lights = {}\n")
  fmt.print("  switch location {\n")
  node_idx := 0
  for name, location in locations {
    fmt.printf("    case .%v:\n", name)
    fmt.println(location.setup)
    fmt.printf("      nodes = (transmute([^]Node)(&node_mem))[%v:%v]\n\n", node_idx, node_idx+len(location.texts))
    node_idx += len(location.texts)
  }
  fmt.print("  }\n")
  fmt.print("}\n\n")

  // fmt.print("@(static)\n")
  fmt.print("DATA_STRING := \"")
  for c in strings.to_string(string_pool) {
    if c == 0 {
      fmt.print("\\x00")
    } else {
      fmt.print(c)
    }
  }
  fmt.print("\"\n\n")

  // fmt.print("@(static)\n")
  fmt.print("DATA_TEXTS := [NodeId]NodeSerial{\n")
  for text in texts {
    data := NodeSerial{
      sense_left_until_revealed = u8(text.sense_required),
      center = text.centered,
      distance = u8(text.distance),
      rotation = u8(text.rotation),
      yaw_pos = u8(text.yaw %% 32),
      pitch_pos = u8(text.pitch + 3),
      disabled = text.disabled,
      action_count = u8(len(text.actions)),
      action1_callback = len(text.actions) >= 1 && text.actions[0].on_use != "",
      action2_callback = len(text.actions) >= 2 && text.actions[1].on_use != "",
      action3_callback = len(text.actions) >= 3 && text.actions[2].on_use != "",
      sense_contour = text.sense_contour != "",
      sense_smell = text.sense_smell != "",
      sense_feel = text.sense_feel != "",
      sense_listen = text.sense_listen != "",
      sense_taste = text.sense_taste != "",
      sense_poke = text.sense_poke != "",
    }
    fmt.printf("  .%v = auto_cast %v,\n", text.key, u32(data))
  }
  fmt.print("}\n\n")

  fmt.print("action_callback :: proc \"contextless\" (idx : u8) {\n")
  fmt.print("  switch idx {\n")
  callback_idx := 1
  for action, idx in actions {
    if action.on_use != "" {
      fmt.printf("\n    case %v:\n", callback_idx)
      callback_idx += 1
      fmt.print(action.on_use)
    }
  }
  fmt.print("\n  }\n")
  fmt.print("}\n\n")
}

add_string :: proc(sb : ^strings.Builder, str : string) {
  if str == "" {
    strings.write_rune(sb, 0)
    strings.write_rune(sb, 0)
    return
  }

  {
    last_can_break := true
    if len(sb.buf) > 0 {
      r := sb.buf[len(sb.buf)-1]
      last_can_break = (r >= 'a' && r <= 'z') || r == '.' || r == '!'
    }
    if str[0] < 'A' || str[0] > 'Z' {
      strings.write_rune(sb, 0)
    }
  }

  last_can_break := false
  for c, i in str {
    if c == '\x00' {
      fmt.eprintf("String \"%v\" contains breaking pattern at: %v!", str, i)
      os.exit(1)
    }
    if last_can_break && c >= 'A' && c <= 'Z' {
      fmt.eprintf("String \"%v\" contains breaking pattern at: %v!", str, i)
      os.exit(1)
    }
    last_can_break = (c >= 'a' && c <= 'z') || c == '.' || c == '!'
    if c == '\n' {
      strings.write_string(sb, "\\n")
    } else if c == '"' {
      strings.write_string(sb, "\\\"")
    } else {
      strings.write_rune(sb, c)
    }
  }
}


to_key :: proc(str : string) -> string {
  s := strings.trim_space(str)
  b: strings.Builder
  strings.builder_init(&b, 0, len(s))
  w := strings.to_writer(&b)

  strings.string_case_iterator(w, s, proc(w: io.Writer, prev, curr, next: rune) {
    if !strings.is_delimiter(curr) && !strings.contains_rune(".!", curr) {
      if strings.is_delimiter(prev) || prev == 0 || (unicode.is_lower(prev) && unicode.is_upper(curr)) {
        if prev != 0 {
          io.write_rune(w, '_')
        }
        io.write_rune(w, unicode.to_upper(curr))
      } else {
        io.write_rune(w, unicode.to_lower(curr))
      }
    }
  })

  return strings.to_string(b)
}
