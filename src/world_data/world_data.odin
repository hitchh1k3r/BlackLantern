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
        shared.mem.lights[0].dir = { 3, 3, 5 }
        shared.mem.lights[0].color = 0.25*{ 1, 1, 0.9 }
        shared.mem.lights[0].spread = 1.0
        shared.mem.lights[0].brightness = 0.5
      `,
      texts = {
        {
          name = "Bed",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 1,
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
              name = "Fluff",
              caption = "Fluffing your bedding brings you comfort.",
              on_use = ``,
            },
            {
              key = "CantSleep",
              name = "Sleep",
              caption = "You are not tired.",
              on_use = ``,
            },
            {
              key = "CanSleep",
              name = "Sleep",
              caption = "",
              on_use = `
                load_location(.Dream_House)
                `,
            },
          },
        },
        {
          name = "Sock",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -9,
          pitch = -3,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "crumpled",
          sense_smell = "dirt, sweat",
          sense_feel = "soft",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
          },
        },
        {
          name = "Floorboard Gap",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 7,
          pitch = -3,
          distance = .D1,
          rotation = .Center,
          sense_required = 1,
          sense_contour = "narrow, deep",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Tap",
              caption = "A dull thock echoes through the wood.",
              on_use = ``,
            },
          },
        },
        {
          name = "Desk",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 13,
          pitch = 1,
          distance = .D3,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "tall, wide",
          sense_smell = "",
          sense_feel = "hard, smooth",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.ChildsRoom_Desk)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Doorway",
          disabled = true,
          centered = false,
          memory = false,
          yaw = -12,
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
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.ChildsRoom_Doorway)
                this_action.used = false
                `,
            },
          },
        },
      },
    },
    "Desk" = Location{
      setup = `
        shared.mem.lights[0].dir = { 10, 2, 0 }
        shared.mem.lights[0].color = 0.75*{ 1, 1, 0.9 }
        shared.mem.lights[0].spread = 1.0
        shared.mem.lights[0].brightness = 0.75
      `,
      texts = {
        {
          name = "Bed",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -8,
          pitch = -3,
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
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.ChildsRoom_Floor)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Window",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 8,
          pitch = 2,
          distance = .D1,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "flat",
          sense_smell = "",
          sense_feel = "cold",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "solid",
          actions = {
            {
              name = "\"hello\"",
              caption = "A small sound escapes into the beyond.",
              on_use = `
                play_sound(.Mew)
                `,
            },
          },
        },
        {
          name = "Pen Holder",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 16,
          pitch = 2,
          distance = .D3,
          rotation = .Center,
          sense_required = 4,
          sense_contour = "tall",
          sense_smell = "waxy",
          sense_feel = "",
          sense_listen = "rattling",
          sense_taste = "",
          sense_poke = "hollow",
          actions = {
            {
              name = "Push",
              caption = "A clattering scatters across the floor.",
              on_use = `
                // play_sound(.Clatter) // TODO
                this_node.disabled = true
                node_mem[.ChildsRoom_Desk_Scattered_Pens].disabled = false
                `,
            },
          },
        },
        {
          name = "Scattered Pens",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 16,
          pitch = -3,
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
              name = "Jump",
              caption = "You hop over to where the pens spilled.",
              on_use = `
                load_location(.ChildsRoom_Doorway)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Paper",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 0,
          pitch = 0,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "thin, flat",
          sense_smell = "",
          sense_feel = "smooth",
          sense_listen = "crackle",
          sense_taste = "",
          sense_poke = "",
          actions = {
          },
        },
        {
          name = "Mug",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 14,
          pitch = 1,
          distance = .D3,
          rotation = .Center,
          sense_required = 4,
          sense_contour = "round",
          sense_smell = "stale",
          sense_feel = "cold, wet",
          sense_listen = "",
          sense_taste = "bitter",
          sense_poke = "",
          actions = {
            {
              name = "Drink",
              caption = "That might have been a mistake.",
              on_use = ``,
            },
            {
              name = "Push",
              caption = "It wobbles, then steadies.",
              on_use = ``,
            },
          },
        },
      }
    },
    "Doorway" = Location{
      setup = `
        shared.mem.lights[0].dir = { 3, 5, -4 }
        shared.mem.lights[0].color = 0.25*{ 1, 1, 0.9 }
        shared.mem.lights[0].spread = 0.66
        shared.mem.lights[0].brightness = 0.66
        node_mem[.ChildsRoom_Floor_Doorway].disabled = false
      `,
      texts = {
        {
          name = "Bed",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 0,
          pitch = 0,
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
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.ChildsRoom_Floor)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Desk",
          disabled = false,
          centered = false,
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
          actions = {
            {
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.ChildsRoom_Desk)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Door",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -10,
          pitch = 4,
          distance = .D3,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "tall",
          sense_smell = "",
          sense_feel = "",
          sense_listen = "squeak",
          sense_taste = "",
          sense_poke = "solid",
          actions = {
            {
              key = "HallDoor_CantGo",
              name = "Leave Room",
              caption = "Not today...",
              on_use = ``,
            },
            {
              key = "HallDoor_CanGo",
              name = "Leave Room",
              caption = "You slip between the door and the wall.",
              on_use = `
                load_location(.LivingRoom_Doorway)
                this_action.used = false
                `,
            }
          },
        },
        {
          name = "Shoes",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -14,
          pitch = -1,
          distance = .D3,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "",
          sense_smell = "strong, sweat",
          sense_feel = "bumpy",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
          },
        },
        {
          name = "Book",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 10,
          pitch = 1,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "square",
          sense_smell = "dusty",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
          },
        },
        {
          name = "Toy Ball",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 13,
          pitch = 1,
          distance = .D1,
          rotation = .Center,
          sense_required = 4,
          sense_contour = "sphere",
          sense_smell = "",
          sense_feel = "smooth",
          sense_listen = "rattle",
          sense_taste = "",
          sense_poke = "rolls",
          actions = {
            {
              name = "Remember",
              caption = "A memory unfurls around you...",
              on_use = `
                load_location(.Memory1)
                `,
            },
          },
        },
      },
    },
  },
  "LivingRoom" = NS{
    "Doorway" = Location{
      setup = `
        shared.mem.lights[0].dir = { 2, 4, 5 }
        shared.mem.lights[0].color = 0.4*{ 1, 1, 0.95 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
        shared.mem.lights[1].dir = { 8, 3, 8 }
        shared.mem.lights[1].color = 0.333*{ 1, 1, 0.5 }
        shared.mem.lights[1].spread = 0.25
        shared.mem.lights[1].brightness = 0.5
      `,
      texts = {
        {
          name = "Hallway",
          disabled = false,
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
              name = "Goto Child's Room",
              caption = "",
              on_use = `
                load_location(.ChildsRoom_Doorway)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Kitchen",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -2,
          pitch = 2,
          distance = .D3,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "doorway",
          sense_smell = "food",
          sense_feel = "",
          sense_listen = "buzzing",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              key = "Kitchen_CantGo",
              name = "Enter",
              caption = "Your water is not that way.",
              on_use = ``,
            },
            {
              key = "Kitchen_CanGo",
              name = "Enter",
              caption = "",
              on_use = `
                load_location(.Kitchen_Doorway)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Rug",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -14,
          pitch = -2,
          distance = .D1,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "",
          sense_smell = "feet",
          sense_feel = "coarse, fuzz",
          sense_listen = "",
          sense_taste = "fuzz",
          sense_poke = "",
          actions = {
            {
              name = "Scratch",
              caption = "Your claws break and curl the threads.",
              on_use = ``,
            },
            {
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.LivingRoom_Rug)
                this_action.used = false
                `,
            },
          },
        },
      }
    },
    "Rug" = Location{
      setup = `
        shared.mem.lights[0].dir = { 2, 4, 2 }
        shared.mem.lights[0].color = 0.66*{ 1, 1, 0.95 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
        shared.mem.lights[1].dir = { 8, 3, 1 }
        shared.mem.lights[1].color = 0.5*{ 1, 1, 0.5 }
        shared.mem.lights[1].spread = 0.5
        shared.mem.lights[1].brightness = 0.25
      `,
      texts = {
        {
          name = "Doorway",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 2,
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
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.LivingRoom_Doorway)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Couch",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 10,
          pitch = 2,
          distance = .D3,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "wide, tall",
          sense_smell = "sun cooked",
          sense_feel = "warm, soft",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "squishy",
          actions = {
            {
              name = "Climb",
              caption = "",
              on_use = `
                load_location(.LivingRoom_Couch)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Water Bowl",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -12,
          pitch = 0,
          distance = .D1,
          rotation = .Center,
          sense_required = 5,
          sense_contour = "shallow, round",
          sense_smell = "clean",
          sense_feel = "cold, wet",
          sense_listen = "",
          sense_taste = "metal, water",
          sense_poke = "sloshy",
          actions = {
            {
              name = "Drink",
              caption = "Cool water, you feel a bit better.",
              on_use = ``,
            },
          },
        },
        {
          name = "Food Bowl",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -8,
          pitch = 0,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "shallow, round",
          sense_smell = "faint food",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "metal, empty",
          sense_poke = "",
          actions = {
          },
        },
      }
    },
    "Couch" = Location{
      setup = `
        shared.mem.lights[0].dir = { -5, 3, -2 }
        shared.mem.lights[0].color = 0.6*{ 1, 1, 0.95 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
        shared.mem.lights[1].dir = { -1, 2, 3 }
        shared.mem.lights[1].color = 0.75*{ 1, 1, 0.5 }
        shared.mem.lights[1].spread = 0.25
        shared.mem.lights[1].brightness = 0.25
      `,
      texts = {
        {
          name = "Rug",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -6,
          pitch = -3,
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
              name = "Goto",
              caption = "",
              on_use = `
                load_location(.LivingRoom_Rug)
                this_action.used = false
                `,
            },
          },
        },
        {
          name = "Knitted Blanket",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 14,
          pitch = 2,
          distance = .D1,
          rotation = .Center,
          sense_required = 2,
          sense_contour = "flat, cloth",
          sense_smell = "yarn",
          sense_feel = "hot",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
            {
              name = "Kneed",
              caption = "Your claws catch in the yarn.",
              on_use = ``,
            },
          },
        },
        {
          name = "Table",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -12,
          pitch = -3,
          distance = .D1,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "flat",
          sense_smell = "",
          sense_feel = "smooth",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "solid",
          actions = {
          },
        },
        {
          name = "Projector",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -12,
          pitch = 2,
          distance = .D3,
          rotation = .Right,
          sense_required = 3,
          sense_contour = "mechanism",
          sense_smell = "burnt dust",
          sense_feel = "plastic",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "",
          actions = {
          },
        },
        {
          name = "Photo Slide",
          disabled = false,
          centered = false,
          memory = false,
          yaw = -9,
          pitch = 1,
          distance = .D3,
          rotation = .Center,
          sense_required = 3,
          sense_contour = "square",
          sense_smell = "plastic, cardboard",
          sense_feel = "",
          sense_listen = "",
          sense_taste = "",
          sense_poke = "flex",
          actions = {
            {
              name = "Remember",
              caption = "This was the fathers...",
              on_use = `
                load_location(.Memory2)
                `,
            },
          },
        },
      }
    },
  },
  "Kitchen" = NS{
    "Doorway" = Location{},
    "Table" = Location{},
    "Counter" = Location{},
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
        yaw = -11,
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
        yaw = -3,
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
        yaw = 5,
        pitch = 0,
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
        yaw = 13,
        pitch = 1,
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
            name = "Remember",
            caption = "This is your home: the floor,\n" +
                      "the ball, the child's eyes on you.\n\n"+
                      "You are tired...",
            on_use = `
              action_mem[.ChildsRoom_Desk_Window_hello].used = false
              reset_dream(.Dream1_Door)
              load_location(.ChildsRoom_Doorway)
              `,
          }
        },
      },
    }
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
      shared.mem.lights[2].dir = { -1, 3, -5 }
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
        yaw = -9,
        pitch = 3,
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
        yaw = -1,
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
        yaw = 7,
        pitch = 3,
        distance = .D1,
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
        yaw = 15,
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
        yaw = -9,
        pitch = 0,
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
                      "Ears are now your eyes.\n\n"+
                      "You are tired...",
            on_use = `
              reset_dream(.Dream2_Door)
              load_location(.LivingRoom_Couch)
              `,
          },
        },
      },
    }
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
                      "Your body gives less with each dawn.\n\n"+
                      "You are tired...",
            on_use = `
              reset_dream(.Dream3_Door)
              load_location(.ChildsRoom_Doorway)
              `,
          }
        },
      },
    }
  },
  "Dream" = NS{
    "House" = Location{
      setup = `
        shared.mem.lights[0].dir = { 0, -1, 0 }
        shared.mem.lights[0].color = 0.5*{ 1, 1, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 1.0
      `,
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
                node_mem[.Dream_House_Table].pos.y *= 1.2
                action_mem[.Dream_House_Table_Climb].used = false
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
                node_mem[.Dream_House_Chair].disabled = true
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
              key = "Dream1_Door",
              name = "Push",
              caption = "The door turns to ash at your touch.",
              on_use = `
                node_mem[.Dream_House_Door].disabled = true
                node_mem[.Dream1_Wake].disabled = false
                `,
            },
            {
              key = "Dream2_Door",
              name = "Push",
              caption = "The door turns to ash at your touch.",
              on_use = `
                node_mem[.Dream_House_Door].disabled = true
                node_mem[.Dream2_Wake].disabled = false
                `,
            },
            {
              key = "Dream3_Door",
              name = "Push",
              caption = "The door turns to ash at your touch.",
              on_use = `
                node_mem[.Dream_House_Door].disabled = true
                node_mem[.Dream_House_Outside].disabled = false
                `,
            }
          },
        },
        {
          key = "Dream1_Wake",
          name = "Outside",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 6,
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
              name = "Wake Up",
              caption = "You are thirsty.",
              on_use = `
                load_location(.ChildsRoom_Floor)
                action_mem[.HallDoor_CantGo].used = true
                action_mem[.HallDoor_CanGo].used = false
                `,
            },
          },
        },
        {
          key = "Dream2_Wake",
          name = "Outside",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 6,
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
              name = "Wake Up",
              caption = "You are hungry.",
              on_use = `
                load_location(.ChildsRoom_Floor)
                action_mem[.Kitchen_CantGo].used = true
                action_mem[.Kitchen_CanGo].used = false
                `,
            },
          },
        },
        {
          name = "Outside",
          disabled = true,
          centered = false,
          memory = false,
          yaw = 6,
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
              name = "Walk Outside",
              caption = "The dream continues...",
              on_use = `
                load_location(.Dream_Outside)
                `,
            },
          },
        },
      }
    },
    "Outside" = Location{
      setup = `
        shared.mem.lights[0].dir = { 0, -1, 0 }
        shared.mem.lights[0].color = 0.5*{ 0.75, 0.75, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 1.0
      `,
      texts = {
        {
          name = "Insignificance",
          disabled = true,
          centered = true,
          memory = false,
          yaw = -1,
          pitch = 1,
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
          pitch = 1,
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
          pitch = 1,
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
              caption = "You claw deep into the bark, but my marks do\n"+
                        "not last, the tree has already forgotten me.",
              on_use = `
                node_mem[.Dream_Outside_Tree].disabled = true
                node_mem[.Dream_Outside_Erasure].disabled = false
                node_mem[.Dream_Outside_Photo_Slide].disabled = false
                node_mem[.Dream_Outside_Toy_Ball].sense_left_until_revealed -= 1
                node_mem[.Dream_Outside_Wooden_Spoon].sense_left_until_revealed -= 1
                `,
            },
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
              caption = "You listen, not for others, but for the\n"+
                        "missing chapter of myself...",
              on_use = `
                node_mem[.Dream_Outside_Street].disabled = true
                node_mem[.Dream_Outside_Unfinishedness].disabled = false
                node_mem[.Dream_Outside_Toy_Ball].disabled = false
                node_mem[.Dream_Outside_Photo_Slide].sense_left_until_revealed -= 1
                node_mem[.Dream_Outside_Wooden_Spoon].sense_left_until_revealed -= 1
                `,
            },
          },
        },
        {
          name = "Moon",
          disabled = false,
          centered = false,
          memory = false,
          yaw = 18,
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
              caption = "You raise my voice to the moon, and it\n"+
                        "answers: nothing has ever known you.",
              on_use = `
                play_sound(.Mewowl)
                node_mem[.Dream_Outside_Moon].disabled = true
                node_mem[.Dream_Outside_Insignificance].disabled = false
                node_mem[.Dream_Outside_Wooden_Spoon].disabled = false
                node_mem[.Dream_Outside_Photo_Slide].sense_left_until_revealed -= 1
                node_mem[.Dream_Outside_Toy_Ball].sense_left_until_revealed -= 1
                `,
            }
          },
        },
        {
          name = "Wooden Spoon",
          disabled = true,
          centered = true,
          memory = true,
          yaw = -1,
          pitch = -2,
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
              on_use = `
                // node_mem[.Dream_Outside_Insignificance].disabled = true
                `,
            },
          },
        },
        {
          name = "Photo Slide",
          disabled = true,
          centered = true,
          memory = true,
          yaw = -11,
          pitch = -2,
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
              on_use = `
                // node_mem[.Dream_Outside_Erasure].disabled = true
                `,
            },
          },
        },
        {
          name = "Toy Ball",
          disabled = true,
          centered = true,
          memory = true,
          yaw = 11,
          pitch = -2,
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
              on_use = `
                // node_mem[.Dream_Outside_Unfinishedness].disabled = true
                `,
            },
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
              caption = "With your memories at hand,\n"+
                        "you drift off to sleep...",
              on_use = `
                load_location(.Credits)
                `,
            },
          },
        },
      }
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
            name = "For Js13k Games 2025",
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
        actions = {},
      },
    }
  },
}
