package main

import "shared"

// Nodes ///////////////////////////////////////////////////////////////////////////////////////////

  Node :: struct {
    disabled : bool,
    name : string,
    sense_left_until_revealed : u8,
    pos : V3,
    right : V3,
    up : V3,
    size : f32,
    reveal : f32,
    actions : []Action,
    center : bool,
  }

  NodeSerial :: struct {
    name : string,
    using _ : bit_field u32 {
      disabled : bool | 1,
      sense_left_until_revealed : u8 | 3, // 0-7

    },
  }
  NodeId :: enum u8 {
    // ChildsRoom
      // Floor
        ChildsRoom_Floor_Bed,

    // Memory 1
      Memory1_Bounce,
      Memory1_Laugh,
      Memory1_Touch,
      Memory1_Home,

    // Memory 2
      Memory2_Lamp,
      Memory2_Light,
      Memory2_Flash,
      Memory2_Dark,
      Memory2_Listen,

    // Memory 3
      Memory3_Stir,
      Memory3_Voice,
      Memory3_Siren,
      Memory3_Ache,

    // Dream 3
      // House
        Dream3_House_Table,
        Dream3_House_Chair,
        Dream3_House_Window,
        Dream3_House_Door,
        Dream3_House_Outside,
      // Outside
        Dream3_Fears_Insignificance,
        Dream3_Fears_Erasure,
        Dream3_Fears_Unfinishedness,
        Dream3_Outside_Tree,
        Dream3_Outside_Street,
        Dream3_Outside_Moon,
        Dream3_Fears_Spoon,
        Dream3_Fears_Slide,
        Dream3_Fears_Ball,
        Dream3_TheEnd_Bed,

    // Credits
      Credits_Made,
      Credits_Thanks,
  }
  node_mem : [NodeId]Node

  init_nodes :: proc "contextless" () {
    node_mem = {
      // Child's Room
        // Floor
          .ChildsRoom_Floor_Bed = {
            name = "Bed",
            sense_left_until_revealed = 3,
            pos = { -0.466962, 0.713784, -0.897095 },
            right = { 1.000000, -0.000000, -0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.ChildsRoom_Floor_Bed_Smell, .ChildsRoom_Floor_Bed_Sleep),
          },
      // Memory 1
        .Memory1_Bounce = {
          name = "Bounce",
          center = true,
          pos = { 0, 0.3, -1 },
          right = { 1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory1_Bounce_Remember, .Memory1_Bounce_Remember),
        },
        .Memory1_Laugh = {
          name = "Laugh",
          center = true,
          pos = { 1, 0.3, 0 },
          right = { 0.000000, 0.000000, 1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory1_Laugh_Remember, .Memory1_Laugh_Remember),
        },
        .Memory1_Touch = {
          name = "Touch",
          center = true,
          pos = { 0, 0.3, 1 },
          right = { -1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory1_Touch_Remember, .Memory1_Touch_Remember),
        },
        .Memory1_Home = {
          name = "Home",
          center = true,
          sense_left_until_revealed = 3,
          pos = { -1, 0.3, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory1_Home_Remember, .Memory1_Home_Remember),
        },
      // Memory 2
        .Memory2_Lamp = {
          name = "Lamp",
          center = true,
          pos = { 0, 0.3, -1 },
          right = { 1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory2_Lamp_Remember, .Memory2_Lamp_Remember),
        },
        .Memory2_Light = {
          name = "Light",
          center = true,
          pos = { 1, 0.3, 0 },
          right = { 0.000000, 0.000000, 1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory2_Light_Remember, .Memory2_Light_Remember),
        },
        .Memory2_Flash = {
          name = "Flash",
          center = true,
          pos = { 0, 0.2, 1 },
          right = { -1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory2_Flash_Remember, .Memory2_Flash_Remember),
        },
        .Memory2_Dark = {
          name = "Dark",
          center = true,
          pos = { -1, 0.2, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory2_Dark_Remember, .Memory2_Dark_Remember),
        },
        .Memory2_Listen = {
          name = "Listen",
          center = true,
          sense_left_until_revealed = 4,
          pos = { -1, 0.7, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory2_Listen_Remember, .Memory2_Listen_Remember),
        },
      // Memory 3
        .Memory3_Stir = {
          name = "Stir",
          center = true,
          pos = { 0, 0.3, -1 },
          right = { 1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory3_Stir_Remember, .Memory3_Stir_Remember),
        },
        .Memory3_Voice = {
          name = "Voice",
          center = true,
          pos = { 1, 0.3, 0 },
          right = { 0.000000, 0.000000, 1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory3_Voice_Remember, .Memory3_Voice_Remember),
        },
        .Memory3_Siren = {
          name = "Siren",
          center = true,
          pos = { 0, 0.2, 1 },
          right = { -1.000000, 0.000000, 0.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory3_Siren_Remember, .Memory3_Siren_Remember),
        },
        .Memory3_Ache = {
          name = "Ache",
          center = true,
          sense_left_until_revealed = 3,
          pos = { -1, 0.2, 0 },
          right = { 0.000000, 0.000000, -1.000000 },
          up = { 0.000000, 1.000000, 0.000000 },
          size = 0.400000,
          actions = action_range(.Memory3_Ache_Remember, .Memory3_Ache_Remember),
        },
      // Dream 3
        // House
          .Dream3_House_Table = {
            name = "Table",
            pos = { -1.5, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_House_Table_Climb, .Dream3_House_Table_Climb),
          },
          .Dream3_House_Chair = {
            name = "Chair",
            pos = { -0.5, 0.0, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_House_Chair_Scratch, .Dream3_House_Chair_Scratch),
          },
          .Dream3_House_Window = {
            name = "Window",
            pos = { 0.5, 0.8, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_House_Window_Look, .Dream3_House_Window_Look),
          },
          .Dream3_House_Door = {
            name = "Door",
            pos = { 1.5, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_House_Door_Push, .Dream3_House_Door_Push),
          },
          .Dream3_House_Outside = {
            disabled = true,
            name = "Outside",
            pos = { 1.5, 0.3, -2 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_House_Outside_MoveTo, .Dream3_House_Outside_MoveTo),
          },
        // Outside
          .Dream3_Fears_Insignificance = {
            disabled = true,
            name = "Insignificance",
            center = true,
            pos = { 0, 2.00, -10 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 2.000000, 0.000000 },
            size = 6.500000,
          },
          .Dream3_Fears_Unfinishedness = {
            disabled = true,
            name = "Unfinishedness",
            center = true,
            pos = { -10, 2.00, 0 },
            right = { 0.000000, 0.000000, -1.000000 },
            up = { 0.000000, 2.000000, 0.000000 },
            size = 6.500000,
          },
          .Dream3_Fears_Erasure = {
            disabled = true,
            name = "Erasure",
            center = true,
            pos = { 10, 2.00, 0 },
            right = { 0.000000, 0.000000, 1.000000 },
            up = { 0.000000, 2.000000, 0.000000 },
            size = 6.500000,
          },
          .Dream3_Outside_Tree = {
            name = "Tree",
            pos = { -1, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_Outside_Tree_Scratch, .Dream3_Outside_Tree_Scratch),
          },
          .Dream3_Outside_Street = {
            name = "Street",
            pos = { 0, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_Outside_Street_Listen, .Dream3_Outside_Street_Listen),
          },
          .Dream3_Outside_Moon = {
            name = "Moon",
            pos = { 1, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_Outside_Moon_Call, .Dream3_Outside_Moon_Call),
          },
          .Dream3_Fears_Spoon = {
            disabled = true,
            name = "Wooden Spoon",
            sense_left_until_revealed = 2,
            pos = { -2, 0.3, 2 },
            right = { -1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_Fear_Spoon_Stir, .Dream3_Fear_Spoon_Stir),
          },
          .Dream3_Fears_Slide = {
            disabled = true,
            name = "Photo Slide",
            sense_left_until_revealed = 2,
            pos = { 0, 0.7, 2 },
            right = { -1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_Fear_Slide_Project, .Dream3_Fear_Slide_Project),
          },
          .Dream3_Fears_Ball = {
            disabled = true,
            name = "Toy Ball",
            sense_left_until_revealed = 2,
            pos = { 2, 0.3, 2 },
            right = { -1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_Fear_Ball_Throw, .Dream3_Fear_Ball_Throw),
          },
        // The End
          .Dream3_TheEnd_Bed = {
            disabled = true,
            name = "Bed",
            sense_left_until_revealed = 3,
            pos = { 0, 0.3, -2 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Dream3_TheEnd_Bed_Rest, .Dream3_TheEnd_Bed_Rest),
          },
        // Credits
          .Credits_Made = {
            name = "A Game Made...",
            pos = { -1, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
            actions = action_range(.Credits_Made_ByHitchh1k3r, .Credits_Made_ForJS13k),
          },
          .Credits_Thanks = {
            name = "Thanks\nFor\nPlaying!",
            center = true,
            pos = { 1, 0.3, -1 },
            right = { 1.000000, 0.000000, 0.000000 },
            up = { 0.000000, 1.000000, 0.000000 },
            size = 0.400000,
          },
    }

    action_range :: #force_inline proc "contextless" ($FIRST, $LAST : ActionId) -> []Action {
      return (transmute([^]Action)(&action_mem))[int(FIRST):int(LAST)+1]
    }
  }

// Actions /////////////////////////////////////////////////////////////////////////////////////////

  Action :: struct {
    disabled : bool,
    needs_reveal : bool,
    name : string,
    used_name : string, // if "", then disabled when used
    used : bool,
    sense_reveal : u8,
    use_progress : f32,
    on_used : #type proc "contextless" (),
  }

  ActionSerial :: struct {
    using _ : bit_field u32 {
    },
  }
  ActionId :: enum u8 {
    ChildsRoom_Floor_Bed_Smell,
    ChildsRoom_Floor_Bed_Feel,
    ChildsRoom_Floor_Bed_Poke,
    ChildsRoom_Floor_Bed_Sleep,

    Memory1_Bounce_Remember,
    Memory1_Laugh_Remember,
    Memory1_Touch_Remember,
    Memory1_Home_Remember,

    Memory2_Lamp_Remember,
    Memory2_Light_Remember,
    Memory2_Flash_Remember,
    Memory2_Dark_Remember,
    Memory2_Listen_Remember,

    Memory3_Stir_Remember,
    Memory3_Voice_Remember,
    Memory3_Siren_Remember,
    Memory3_Ache_Remember,

    Dream3_House_Table_Climb,
    Dream3_House_Chair_Scratch,
    Dream3_House_Window_Look,
    Dream3_House_Door_Push,
    Dream3_House_Outside_MoveTo,

    Dream3_Outside_Tree_Scratch,
    Dream3_Outside_Street_Listen,
    Dream3_Outside_Moon_Call,

    Dream3_Fear_Spoon_Stir,
    Dream3_Fear_Slide_Project,
    Dream3_Fear_Ball_Throw,

    Dream3_TheEnd_Bed_Rest,

    Credits_Made_ByHitchh1k3r,
    Credits_Made_In13KB,
    Credits_Made_ForJS13k,
  }
  action_mem : [ActionId]Action

  init_actions :: proc "contextless" () {
    action_mem = {
      // Child's Room
        // Floor
          // Bed
            .ChildsRoom_Floor_Bed_Smell = {
              name = "Smell",
              used_name = "self",
              sense_reveal = 1,
            },
            .ChildsRoom_Floor_Bed_Feel = {
              name = "Feel",
              used_name = "soft",
              sense_reveal = 1,
            },
            .ChildsRoom_Floor_Bed_Poke = {
              name = "Poke",
              used_name = "squish",
              sense_reveal = 1,
            },
            .ChildsRoom_Floor_Bed_Sleep = {
              needs_reveal = true,
              name = "Sleep",
              used_name = "too lonely",
              on_used = proc "contextless" () {
                caption("You are too lonely to sleep right now.")
              },
            },
      // Memory 1
        .Memory1_Bounce_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory1_Home].sense_left_until_revealed -= 1
            node_mem[.Memory1_Bounce].name = "The child tosses the ball across the floor.\n" +
                                         "You spring after it, paws clumsy, heart quick."
            node_mem[.Memory1_Bounce].size = 0.1
          },
        },
        .Memory1_Laugh_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory1_Home].sense_left_until_revealed -= 1
            node_mem[.Memory1_Laugh].name = "High, bright sounds fill the room. The child\n"+
                                        "clapping as you press the ball with your nose."
            node_mem[.Memory1_Laugh].size = 0.1
          },
        },
        .Memory1_Touch_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory1_Home].sense_left_until_revealed -= 1
            node_mem[.Memory1_Touch].name = "Small fingers press into your fur.\n"+
                                        "Warmth, gentle and proud."
            node_mem[.Memory1_Touch].size = 0.1
          },
        },
        .Memory1_Home_Remember = {
          needs_reveal = true,
          name = "Remember",
          on_used = proc "contextless" () {
            caption("This is your home: the floor,\n"+
                    "the ball, the child's eyes on you.")
            load_location(.Day2_Memory)
          },
        },
      // Memory 2
        .Memory2_Lamp_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory2_Listen].sense_left_until_revealed -= 1
            node_mem[.Memory2_Lamp].name = "The father clicks on the lamp.\n"+
                                       "Dust dances in the beam."
            node_mem[.Memory2_Lamp].size = 0.1
            shared.mem.lights[2].color = 0.9*{ 1, 1, 0 }
          },
        },
        .Memory2_Light_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory2_Listen].sense_left_until_revealed -= 1
            node_mem[.Memory2_Light].name = "The slides glow, projected onto the wall.\n"+
                                        "Shapes and faces; your families frozen smiles."
            node_mem[.Memory2_Light].size = 0.1
          },
        },
        .Memory2_Flash_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory2_Listen].sense_left_until_revealed -= 1
            node_mem[.Memory2_Flash].name = "At the window: a brilliance greater than\n"+
                                        "the projection, greater than the sun.\n"+
                                        "It consumed everything, sight burned away."
            node_mem[.Memory2_Flash].size = 0.1
            shared.mem.lights[0].color = { 1, 1, 1 }
            shared.mem.lights[0].spread = 1.0
            shared.mem.lights[1] = {}
          },
        },
        .Memory2_Dark_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory2_Listen].sense_left_until_revealed -= 1
            node_mem[.Memory2_Dark].name = "The lamp off, the light faded, the picture\n"+
                                       "vanished. The images remain only in memory."
            node_mem[.Memory2_Dark].size = 0.1
            shared.mem.lights[0].color = 0
            shared.mem.lights[1] = {}
            shared.mem.lights[2].color = 0
          },
        },
        .Memory2_Listen_Remember = {
          needs_reveal = true,
          name = "Remember",
          on_used = proc "contextless" () {
            caption("Without vision: sound is your guide.\n"+
                    "Ears are now your eyes.")
            load_location(.Day3_Memory)
          },
        },
      // Memory 3
        .Memory3_Stir_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory3_Ache].sense_left_until_revealed -= 1
            node_mem[.Memory3_Stir].name = "The spoon circles in the pot. The air\n"+
                                       "fills with scents of comfort and love."
            node_mem[.Memory3_Stir].size = 0.1
          },
        },
        .Memory3_Voice_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory3_Ache].sense_left_until_revealed -= 1
            node_mem[.Memory3_Voice].name = "The mother hums,\n"+
                                        "her tune wraps around the kitchen."
            node_mem[.Memory3_Voice].size = 0.1
          },
        },
        .Memory3_Siren_Remember = {
          name = "Remember",
          on_used = proc "contextless" () {
            node_mem[.Memory3_Ache].sense_left_until_revealed -= 1
            node_mem[.Memory3_Siren].name = "The song ends in a sudden wail.\n"+
                                        "Not a song nor wind, but a warning.\n"+
                                        "They drop everything and run."
            node_mem[.Memory3_Siren].size = 0.1
            play_sound({ 0.0, 6.708, 13.125, 18.933 }, { 402, 430, 430, 402, 402, 818, 818, 402, 402, 1248, 1248, 402, 402, 1687, 1687, 402, 402, 2099, 2099, 402, 402, 2455, 2455, 402 }, { 0.001, 0.1, 0.1, 0.001, 0.001, 0.2, 0.2, 0.001, 0.001, 0.05, 0.05, 0.001, 0.001, 0.065, 0.065, 0.001, 0.001, 0.04, 0.04, 0.001, 0.001, 0.02, 0.02, 0.001 })
          },
        },
        .Memory3_Ache_Remember = {
          needs_reveal = true,
          name = "Remember",
          on_used = proc "contextless" () {
            caption("White fire swallows the sky, your chest\n"+
                    "tightens, steps grow heavier.\n"+
                    "Your body gives less with each dawn.")
            load_location(.ChildsRoom_Floor)
          },
        },
      // Dream 3
        // House
          .Dream3_House_Table_Climb = {
            name = "Climb",
            on_used = proc "contextless" () {
              caption("The higher you climb, the taller the table gets.")
              node_mem[.Dream3_House_Table].pos.y *= 1.2
              action_mem[.Dream3_House_Table_Climb].used = false
            },
          },
          .Dream3_House_Chair_Scratch = {
            name = "Scratch",
            on_used = proc "contextless" () {
              caption("The chair becomes a pile of splinters.")
              node_mem[.Dream3_House_Chair].disabled = true
            },
          },
          .Dream3_House_Window_Look = {
            name = "Look",
            on_used = proc "contextless" () {
              caption("There is only darkness outside.")
            },
          },
          .Dream3_House_Door_Push = {
            name = "Push",
            on_used = proc "contextless" () {
              caption("The door turns to ash at your touch.")
              node_mem[.Dream3_House_Door].disabled = true
              node_mem[.Dream3_House_Outside].disabled = false
            },
          },
          .Dream3_House_Outside_MoveTo = {
            name = "Walk Outside",
            on_used = proc "contextless" () {
              load_location(.Day3_Dream_Outside)
            },
          },
        // Outside
          .Dream3_Outside_Tree_Scratch = {
            name = "Scratch",
            on_used = proc "contextless" () {
              caption("I claw deep into the bark, but my marks do\n"+
                      "not last, the tree has already forgotten me.")
              node_mem[.Dream3_Outside_Tree].disabled = true
              node_mem[.Dream3_Fears_Erasure].disabled = false
              node_mem[.Dream3_Fears_Slide].disabled = false
              node_mem[.Dream3_Fears_Ball].sense_left_until_revealed -= 1
              node_mem[.Dream3_Fears_Spoon].sense_left_until_revealed -= 1
            },
          },
          .Dream3_Outside_Street_Listen = {
            name = "Listen",
            on_used = proc "contextless" () {
              caption("I listen, not for others, but for the\n"+
                      "missing chapter of myself...")
              node_mem[.Dream3_Outside_Street].disabled = true
              node_mem[.Dream3_Fears_Unfinishedness].disabled = false
              node_mem[.Dream3_Fears_Ball].disabled = false
              node_mem[.Dream3_Fears_Slide].sense_left_until_revealed -= 1
              node_mem[.Dream3_Fears_Spoon].sense_left_until_revealed -= 1
            },
          },
          .Dream3_Outside_Moon_Call = {
            name = "Call Out",
            on_used = proc "contextless" () {
              caption("I raise my voice to the moon, and it\n"+
                      "answers: nothing has ever known you.")
              node_mem[.Dream3_Outside_Moon].disabled = true
              node_mem[.Dream3_Fears_Insignificance].disabled = false
              node_mem[.Dream3_Fears_Spoon].disabled = false
              node_mem[.Dream3_Fears_Slide].sense_left_until_revealed -= 1
              node_mem[.Dream3_Fears_Ball].sense_left_until_revealed -= 1
            },
          },
        // Fears
          .Dream3_Fear_Spoon_Stir = {
            needs_reveal = true,
            name = "Stir",
            on_used = proc "contextless" () {
              caption("A single act of care ripples outward,\n"+
                      "until Insignificance drowns in its waves.")
              node_mem[.Dream3_Fears_Insignificance].disabled = true
              node_mem[.Dream3_TheEnd_Bed].disabled = false
              node_mem[.Dream3_TheEnd_Bed].sense_left_until_revealed -= 1
            },
          },
          .Dream3_Fear_Slide_Project = {
            needs_reveal = true,
            name = "Project",
            on_used = proc "contextless" () {
              caption("Erasure burns away in the projected light,\n"+
                      "each copy reigniting the lamp.")
              node_mem[.Dream3_Fears_Erasure].disabled = true
              node_mem[.Dream3_TheEnd_Bed].disabled = false
              node_mem[.Dream3_TheEnd_Bed].sense_left_until_revealed -= 1
            },
          },
          .Dream3_Fear_Ball_Throw = {
            needs_reveal = true,
            name = "Throw",
            on_used = proc "contextless" () {
              caption("With no start nor end, a circle defies\n"+
                      "Unfinishedness; the cycle of play\n"+
                      "completes itself.")
              node_mem[.Dream3_Fears_Unfinishedness].disabled = true
              node_mem[.Dream3_TheEnd_Bed].disabled = false
              node_mem[.Dream3_TheEnd_Bed].sense_left_until_revealed -= 1
            },
          },
        // The End
          .Dream3_TheEnd_Bed_Rest = {
            needs_reveal = true,
            name = "Rest",
            on_used = proc "contextless" () {
              load_location(.Credits)
            },
          },
        // Credits
          .Credits_Made_ByHitchh1k3r = {
            used = true,
            used_name = "By HitchH1k3r",
          },
          .Credits_Made_In13KB = {
            used = true,
            used_name = "In 13 Kibibytes",
          },
          .Credits_Made_ForJS13k = {
            used = true,
            used_name = "For JS13K 2025",
          },
    }
  }

// Location ////////////////////////////////////////////////////////////////////////////////////////

  Location :: enum {
    ChildsRoom_Floor,
    Day1_Memory,
    Day2_Memory,
    Day3_Memory,
    Day3_Dream_House,
    Day3_Dream_Outside,
    Credits,
  }

  load_location :: proc "contextless" (location : Location) {
    shared.mem.lights = {}
    switch location {
      case .ChildsRoom_Floor:
        shared.mem.lights[0].dir = { 0, 0, -1 }
        shared.mem.lights[0].color = 0.25*{ 0.9, 0.9, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.5
        nodes = node_range(.ChildsRoom_Floor_Bed, .ChildsRoom_Floor_Bed)
      case .Day1_Memory:
        shared.mem.lights[0].dir = { 0, 1, 0 }
        shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.9
        shared.mem.lights[1].dir = { 0, -1, 0 }
        shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
        shared.mem.lights[1].spread = 0.5
        shared.mem.lights[1].brightness = 0.9
        nodes = node_range(.Memory1_Bounce, .Memory1_Home)
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
        nodes = node_range(.Memory2_Lamp, .Memory2_Listen)
      case .Day3_Memory:
        shared.mem.lights[0].dir = { 0, 1, 0 }
        shared.mem.lights[0].color = 0.75*{ 1, 1, 1 }
        shared.mem.lights[0].spread = 0.5
        shared.mem.lights[0].brightness = 0.9
        shared.mem.lights[1].dir = { 0, -1, 0 }
        shared.mem.lights[1].color = 0.75*{ 1, 1, 1 }
        shared.mem.lights[1].spread = 0.5
        shared.mem.lights[1].brightness = 0.9
        nodes = node_range(.Memory3_Stir, .Memory3_Ache)
      case .Day3_Dream_House:
        nodes = node_range(.Dream3_House_Table, .Dream3_House_Outside)
      case .Day3_Dream_Outside:
        nodes = node_range(.Dream3_Fears_Insignificance, .Dream3_TheEnd_Bed)
      case .Credits:
        nodes = node_range(.Credits_Made, .Credits_Thanks)

    }

    node_range :: #force_inline proc "contextless" ($FIRST, $LAST : NodeId) -> []Node {
      return (transmute([^]Node)(&node_mem))[int(FIRST):int(LAST)+1]
    }
  }
