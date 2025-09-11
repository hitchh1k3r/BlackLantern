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
              play_sound(.Siren, 3)
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
                node_mem[.Dream3_House_Outside].disabled = false
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
                play_sound(.Mewowl)
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
          centered = true,
          memory = true,
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
          centered = true,
          memory = true,
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
          centered = true,
          memory = true,
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
          centered = true,
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
    setup = `action_speed = 0.5`,
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
