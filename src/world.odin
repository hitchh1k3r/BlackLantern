package main

import "shared"

// Nodes ///////////////////////////////////////////////////////////////////////////////////////////

  CR_FLOOR_BED :: 0
  MEM1_BOUNCE  :: 1
  MEM1_LAUGH   :: 2
  MEM1_TOUCH   :: 3
  MEM1_HOME    :: 4
  MEM2_LAMP    :: 5
  MEM2_LIGHT   :: 6
  MEM2_FLASH   :: 7
  MEM2_DARK    :: 8
  MEM2_LISTEN  :: 9

  NODE_COUNT   :: 10
  node_mem : [NODE_COUNT]Node

  init_nodes :: proc "contextless" () {
    node_mem = {
      // Child's Room
        // Floor
          {
            name = "Bed",
            sense_left_until_revealed = 3,
            pos = { -0.466962, 0.713784, -0.897095 },
            right = { 1.000000, -0.000000, -0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_mem[CR_FLOOR_BED_SLEEP:CR_FLOOR_BED_POKE+1],
          },
      // Memory 1
        {
          name = "Bounce",
          center = true,
          pos = { 0, 0.3, -1 },
          right = { 1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM1_BOUNCE_REMEMBER:MEM1_BOUNCE_REMEMBER+1],
        },
        {
          name = "Laugh",
          center = true,
          pos = { 1, 0.3, 0 },
          right = { 0.000000, 0.000000, 1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM1_LAUGH_REMEMBER:MEM1_LAUGH_REMEMBER+1],
        },
        {
          name = "Touch",
          center = true,
          pos = { 0, 0.3, 1 },
          right = { -1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM1_TOUCH_REMEMBER:MEM1_TOUCH_REMEMBER+1],
        },
        {
          name = "Home",
          center = true,
          sense_left_until_revealed = 3,
          pos = { -1, 0.3, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM1_HOME_REMEMBER:MEM1_HOME_REMEMBER+1],
        },
      // Memory 2
        {
          name = "Lamp",
          center = true,
          pos = { 0, 0.3, -1 },
          right = { 1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM2_LAMP_REMEMBER:MEM2_LAMP_REMEMBER+1],
        },
        {
          name = "Light",
          center = true,
          pos = { 1, 0.3, 0 },
          right = { 0.000000, 0.000000, 1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM2_LIGHT_REMEMBER:MEM2_LIGHT_REMEMBER+1],
        },
        {
          name = "Flash",
          center = true,
          pos = { 0, 0.2, 1 },
          right = { -1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM2_FLASH_REMEMBER:MEM2_FLASH_REMEMBER+1],
        },
        {
          name = "Dark",
          center = true,
          pos = { -1, 0.2, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM2_DARK_REMEMBER:MEM2_DARK_REMEMBER+1],
        },
        {
          name = "Listen",
          center = true,
          sense_left_until_revealed = 4,
          pos = { -1, 0.7, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_mem[MEM2_LISTEN_REMEMBER:MEM2_LISTEN_REMEMBER+1],
        },
    }
  }

// Actions /////////////////////////////////////////////////////////////////////////////////////////

  CR_FLOOR_BED_SLEEP   :: 0
  CR_FLOOR_BED_SMELL   :: 1
  CR_FLOOR_BED_FEEL    :: 2
  CR_FLOOR_BED_POKE    :: 3
  MEM1_BOUNCE_REMEMBER :: 4
  MEM1_LAUGH_REMEMBER  :: 5
  MEM1_TOUCH_REMEMBER  :: 6
  MEM1_HOME_REMEMBER   :: 7
  MEM2_LAMP_REMEMBER   :: 8
  MEM2_LIGHT_REMEMBER  :: 9
  MEM2_FLASH_REMEMBER  :: 10
  MEM2_DARK_REMEMBER   :: 11
  MEM2_LISTEN_REMEMBER :: 12

  ACTION_COUNT         :: 13
  action_mem : [ACTION_COUNT]Action

  init_actions :: proc "contextless" () {
    action_mem = {
      // Child's Room
        // Floor
          // Bed
            {
              needs_reveal = true,
              name = "Sleep",
              // used_name = "too lonely",
              on_used = proc "contextless" () {
                caption("You are too lonely to sleep right now.")
                play_sound({ 0, 1 }, { 440, 880 }, { 0.5, 0.0 })
              },
            },
            {
              name = "Smell",
              used_name = "self",
              sense_reveal = 1,
            },
            {
              name = "Feel",
              used_name = "soft",
              sense_reveal = 1,
            },
            {
              name = "Poke",
              used_name = "squish",
              sense_reveal = 1,
            },
      // Memory 1
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM1_HOME].sense_left_until_revealed -= 1
            node_mem[MEM1_BOUNCE].name = "The child tosses the ball across the floor.\n" +
                                         "You spring after it, paws clumsy, heart quick."
            node_mem[MEM1_BOUNCE].size = 0.1
          },
        },
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM1_HOME].sense_left_until_revealed -= 1
            node_mem[MEM1_LAUGH].name = "High, bright sounds fill the room. The child\n"+
                                        "clapping as you press the ball with your nose."
            node_mem[MEM1_LAUGH].size = 0.1
          },
        },
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM1_HOME].sense_left_until_revealed -= 1
            node_mem[MEM1_TOUCH].name = "Small fingers press into your fur.\n"+
                                        "Warmth, gentle and proud."
            node_mem[MEM1_TOUCH].size = 0.1
          },
        },
        {
          needs_reveal = true,
          name = "Remember",
          on_used = proc "contextless" () {
            caption("This is your home: the floor,\n"+
                    "the ball, the child's eyes on you.")
            load_location(.Day2_Memory)
          },
        },
      // Memory 2
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM2_LISTEN].sense_left_until_revealed -= 1
            node_mem[MEM2_LAMP].name = "The father clicks on the lamp.\n"+
                                       "Dust dances in the beam."
            node_mem[MEM2_LAMP].size = 0.1
            shared.mem.lights[2].color = 0.9*{ 1, 1, 0 }
          },
        },
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM2_LISTEN].sense_left_until_revealed -= 1
            node_mem[MEM2_LIGHT].name = "The slides glow, projected onto the wall.\n"+
                                        "Shapes and faces; your families frozen smiles."
            node_mem[MEM2_LIGHT].size = 0.1
          },
        },
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM2_LISTEN].sense_left_until_revealed -= 1
            node_mem[MEM2_FLASH].name = "At the window: a brilliance greater than\n"+
                                        "the projection, greater than the sun.\n"+
                                        "It consumed everything, sight burned away."
            node_mem[MEM2_FLASH].size = 0.1
            shared.mem.lights[0].color = { 1, 1, 1 }
            shared.mem.lights[0].spread = 1.0
            shared.mem.lights[1] = {}
          },
        },
        {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[MEM2_LISTEN].sense_left_until_revealed -= 1
            node_mem[MEM2_DARK].name = "The lamp off, the light faded, the picture\n"+
                                       "vanished. The images remain only in memory."
            node_mem[MEM2_DARK].size = 0.1
            shared.mem.lights[0].color = 0
            shared.mem.lights[1] = {}
            shared.mem.lights[2].color = 0
          },
        },
        {
          needs_reveal = true,
          name = "Remember",
          on_used = proc "contextless" () {
            caption("Without vision: sound is your guide.\n"+
                    "Ears are now your eyes.")
            load_location(.ChildsRoom_Floor)
          },
        },
    }
  }

// Location ////////////////////////////////////////////////////////////////////////////////////////

  Location :: enum {
    ChildsRoom_Floor,
    Day1_Memory,
    Day2_Memory,
  }

  load_location :: proc "contextless" (location : Location) {
    shared.mem.lights = {}
    switch location {
      case .ChildsRoom_Floor:
        shared.mem.lights[0].dir = { 0, 0, -1 }
        shared.mem.lights[0].color = 0.25*{ 0.9, 0.9, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
        nodes = node_mem[CR_FLOOR_BED:CR_FLOOR_BED+1]
      case .Day1_Memory:
        shared.mem.lights[0].dir = { 0, 1, 0 }
        shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.9
        shared.mem.lights[1].dir = { 0, -1, 0 }
        shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
        shared.mem.lights[1].spread = 0.5
        shared.mem.lights[1].brightness = 0.9
        nodes = node_mem[MEM1_BOUNCE:MEM1_HOME+1]
      case .Day2_Memory:
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
        nodes = node_mem[MEM2_LAMP:MEM2_LISTEN+1]
    }
  }
