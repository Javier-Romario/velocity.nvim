# Velocity.nvim

## Window TODO:

- we wanna probably set (border) in the opts
- nvim_create_buf makes a buffer either "listed" or "scratch", If we wanna pause the reader we should think about making it a listed buffer

### Animation

- ✅ Loop through the words
- ✅ Make a timer
- Speed
  - Make speed editable +/-
  - Have a base speed set in the opts

## Speed reader TODO:

- Add highlight to the correct character
- ½✅ Make top and bottom border lines point at the focus char
- ✅ Make some padding to place the first word in the middle

## Plugin TODO:

- Keymaps

  - Need to set keymaps and events for: start_reading, pause_reading, end_reading

- Modes

  - Take a file
  - Take a selection

- Controls
  - Play / Pause
  - Stop
