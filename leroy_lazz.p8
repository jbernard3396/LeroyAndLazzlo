pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	p = {}
	p.x = 56
	p.y = 56
	p.facing = 1
	friend = {}
	friend.flight = false
	cur_map_x = 1
	cur_map_y = 1
	init_turn_timer = 5
	turn_timer = init_turn_timer
	arrow_array = {}
	target = nil
	player = nil
	setup_enemies()
	text_array = {'hello', 'i am your best firend forever', 'where are your wings??????'}
	text = 'in the beginning was the word and the word was with god and the word was god'
	in_dialogue = true
end

function _update()
 get_move() 
 turn_timer -= 1
 update_arrows()
end

function _draw()
 cls()
 draw_map()
 draw_arrows()
 draw_player()
 draw_texts()
 debug()
end
-->8
--draw help
function draw_player()
	if p.facing == 0 then -- left
 	spr(18, p.x, p.y)
 elseif p.facing == 1 then -- right
 	spr(19, p.x, p.y)
 elseif p.facing == 2 then -- up
 	spr(21, p.x, p.y)
	elseif p.facing == 3 then -- down
 	spr(20, p.x, p.y)
 end
end

function draw_map()
 if friend.flight then
  draw_full_map()
 else 
  draw_partial_map()
 end
end

function draw_full_map()
 local x = cur_map_x
 local y = cur_map_y
 map(16*x,16*y,0,0,16,16)
end

function draw_partial_map()
 local x = cur_map_x
 local y = cur_map_y
 map(16*x+(p.x/8)-3, 16*y+(p.y/8)-3, p.x-24, p.y-24, 7, 7)
end

function draw_arrows()
 for arrow in all(arrow_array) do
  draw_arrow(arrow)
 end
end

function draw_arrow(arrow)
 local x = cur_map_x
 local y = cur_map_y
 map(16*x+(arrow.x/8)-1, 16*y+(arrow.y/8)-1, arrow.x-8, arrow.y-8, 3, 3)
 spr(arrow.sprite, arrow.x, arrow.y)
end

function draw_texts()
 if #text_array > 0 then
  draw_text(text_array[1])
 end
end

function draw_text(text)
 if text == '' or text == nil then
  return
 end
 local text_copy = text
 line_beginning_x = 16
 line_beginning_y = 24
 line_height = 8
 line_length = 24
 char_count = #text
 line_count = ceil(char_count/line_length)
 local pointer_x = 0
 local new_pointer = 0
 local line_pointer = 0
 local new_line_pointer = 0
 draw_box(line_beginning_x-2, line_beginning_y-2, (line_length*4), (line_count*line_height))
 for i=0, 1000 do
  word = get_next_word(text_copy)
  new_pointer = pointer_x + #word
  if new_pointer > line_length then
   pointer_x = 0
   new_pointer = pointer_x + #word
   new_line_pointer = line_pointer+1
   line_pointer = new_line_pointer
  end
  print(word ,line_beginning_x+pointer_x*4, line_beginning_y+line_height*line_pointer)
  pointer_x = new_pointer
  line_pointer = new_line_pointer
  text_copy = sub(text_copy, #word+1)
 end
end

function draw_box(x, y, w, h)
 rectfill(x, y, x+w, y+h, 0)
 rect(x, y, x+w, y+h, 1)
 print('',0,0,7)
end
-->8
--player controller
function get_move()
 if in_dialogue then
  progress_dialogue()
 return 
 end
	if btn(5) then
	 fly()
	elseif not btn(5) then 
	 land()
	 if btnp(4) then
 	 shoot()
 	elseif btnp(0) then
 	 move_left()
 	elseif btnp(1) then
 	 move_right()
 	elseif btnp(2) then
 	 move_up()
 	elseif btnp(3) then
 	 move_down()
	 end
	 update_map()
	 check_for_button()
	end
end

function progress_dialogue()
 if not (btnp() == 0) then
  del(text_array, text_array[1])
 end
 if text_array[1] == nil then
  in_dialogue = false
 end
end

function fly()
 friend.flight = true
end

function land()
 friend.flight = false
end

function shoot()
 fire_arrow(p.x, p.y, p.facing)
end

function move_left()
 p.facing = 0
 if can_move(p.x-8, p.y) then
  p.x -= 8
 end
end

function move_right()
 p.facing = 1
 if can_move(p.x+8, p.y) then
  p.x += 8
 end
end

function move_up()
 p.facing = 2
 if can_move(p.x, p.y-8) then
  p.y -= 8
 end
end

function move_down()
 p.facing = 3
 if can_move(p.x, p.y+8) then
  p.y += 8 
 end
end

function can_move(x, y)
 return not is_obstacle(x, y)
end

-->8
--other controller
function fire_arrow(x, y, direction)
 local is_x = true
 local is_positive = true
 local x = p.x
 local y = p.y
 if direction == 0 then
  x-=8
 elseif direction == 1 then
  x+=8 
 elseif direction == 2 then
  y-=8 
 elseif direction == 3 then
  y+=8 
 end
 if is_obstacle(x, y) then
  create_arrow(x, y, direction)
  arrow_dead(arrow,x,y)
 else
  create_arrow(x, y, direction)
 end
end

function create_arrow(x, y, direction)
 first_arrow_sprite = 48
 arrow = {}
 arrow.x = x
 arrow.y = y
 arrow.direction = direction
 arrow.dead = false
 arrow.sprite = direction+first_arrow_sprite
 add(arrow_array, arrow)
 return arrow
end

function update_arrows()
 for arrow in all(arrow_array) do
  if is_obstacle(arrow.x, arrow.y) then
   arrow_in_obstacle(arrow)
  else
   local new_x = arrow.x
   local new_y = arrow.y
   if arrow.direction == 0 then
    new_x -= 8
   elseif arrow.direction == 1 then
    new_x += 8
   elseif arrow.direction == 2 then
    new_y -= 8
   elseif arrow.direction == 3 then
    new_y += 8
   end
   if arrow.dead and arrow.dead_time < 5 then
    arrow.dead_time +=1
   elseif arrow.dead and arrow.dead_time >= 5 then 
    arrow_dead(arrow, new_x, new_y)
   end
   if not get_bit(new_x, new_y, 1) then --should be is🅾️bstacle
    arrow.x = new_x
    arrow.y = new_y 
   else
    arrow_collision(arrow)
   end
  end
 end
end

function arrow_in_obstacle(arrow)
 local x = 16*(cur_map_x)+arrow.x/8
 local y = 16*(cur_map_y)+arrow.y/8
 hit_target(x, y)
end

function arrow_collision(arrow) 
 if arrow.dead == false then
  arrow.dead_time = 0
  arrow.dead = true
   --play sound and do...nothing?
 end
end

function arrow_dead(arrow, x, y)
 local target_pos_x = 16*(cur_map_x)+x/8
 local target_pos_y = 16*(cur_map_y)+y/8
 hit_target(arrow, target_pos_x, target_pos_y)
end

function hit_target(arrow, x, y)
 target = mget(x, y)
 dir_target = index(enemy_array, target)
 if dir_target then
  if dir_target + arrow.direction == 1 or dir_target + arrow.direction == 5 then
   mset(x, y, 0)
  end
 end
 del(arrow_array, arrow)
end

function delete_arrows()
 for arrow in all(arrow_array) do
  del(arrow_array, arrow)
 end
end

function update_map()
 if p.x < 0 then
  p.x = 120
  cur_map_x -= 1
  reset_map()
 end
 if p.x > 120 then
  p.x = 0
  cur_map_x += 1
  reset_map()
 end
 if p.y < 0 then
  p.y = 120
  cur_map_y -= 1
  reset_map()
 end
 if p.y > 120 then
  p.y = 0
  cur_map_y += 1
  reset_map()
 end
end

function reset_map()
 delete_arrows()
end


-->8
--helper functions

function get_bit(x, y, bit)
 local map_x = cur_map_x
 local map_y = cur_map_y
 return fget(mget(16*map_x+x/8,16*map_y+y/8),bit)
end

function is_obstacle(x, y)
 return get_bit(x, y, 1)
end

-->8
-- imani!

-- buttons!
function check_for_button()
	if is_red_button() then
		press_red()
	elseif is_blue_button() then
		press_blue()
	end
end

function press_red()
	start_row = cur_map_x*16
	start_col = cur_map_y*16
	mset(start_row+(p.x/8), start_col+(p.y/8), 8)
	for row = start_row, start_row+16 do
		for col = start_col, start_col+16 do
			if mget(row,col) == 15 then
				wall_back_red(row,col)
			elseif mget(row,col) == 10 then
				wall_gone_blue(row,col)
			elseif mget(row,col) == 6 then
				mset(row,col,5)
			end
		end
	end
end

function press_blue()
	start_row = cur_map_x*16
	start_col = cur_map_y*16
	mset(start_row+(p.x/8), start_col+(p.y/8), 6)
	for row = start_row, start_row+16 do
		for col = start_col, start_col+16 do
			if mget(row,col) == 16 then
				wall_back_blue(row,col)
			elseif mget(row,col) == 9 then
				wall_gone_red(row,col)
			elseif mget(row,col) == 8 then
				mset(row,col,7)
			end
		end
	end
end


function is_red_button()
	return get_bit(p.x,p.y,5)
end

function is_blue_button()
	return get_bit(p.x,p.y,4)
end

function wall_gone_red(row,col)
	mset(row, col, 15)
end

function wall_gone_blue(row,col)
	mset(row, col, 16)
	test = true
	row_d = row
	col_d = col
end

function wall_back_red(row,col)
	mset(row, col, 9)
end

function wall_back_blue(row,col)
	mset(row, col, 10)
end

-->8
function setup_enemies()
 enemy_array = {14, 13, 12, 11} 
end

function index(array, value)
 local iter = 0
 for i=1, #array+1 do
  if array[i] == value then
   return iter
  end
  iter+=1
 end
end

function get_next_word(text)
 for i=0, #text do
  if sub(text, i, i+0) == " " then
   return sub(text, 0, i)
  end
 end
 return text
end

function populate_text(text)
 add(text_array, text)
end

-->8
-- debug
function debug()
	print(target, 0, 0)
	print(player, 0, 10)
	print(btnp(), 70, 0)
	print(#get_next_word(text), 70, 10)
end

__gfx__
00000000600440060000000000050000555555550000000000000000000000000000000000080800000c0c0000000000066f0000044444000044444008080808
00000000600440060000400000c66c00500505050666666006666660066666600666666000080800000c0c0044446554000ff00004f7470660747f4080000000
007007006011110600000440006666005555555506cccc5006111160068888500622226088888888cccccccc4ff5555047f5f55004ffff0660ffff4000000008
0007700060111106444440440dddddd05005050506cccc5006111160068888500622226000080800000c0c0047f5555044f55554045555ffff55554080000000
0007700060111106000000440dddddd05555555506cccc5006111160068888500622226088888888cccccccc44f5555447f5555006555ff00ff5556000000008
0070070060000006000044400dddddd05005050506cccc5006111160068888500622226000080800000c0c0047f5f5504ff55550055555000055555080000000
0000000060000006000440000dddddd0500505050655555006666660065555500666666000080800000c0c00000ff00044446554055555000055555000000008
00000000666666660000000000000000555555550000000000000000000000000000000000080800000c0c00066f000000000000040040000004004080808080
0c0c0c0c000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00000000089800000ffff0000ffff0000ffff0000f7f700a000000a0000000000ccccc000000000000000000000000000000000000000000000000000000000
0000000c00899800007f7f0000f7f70000ffff0000ffff00aa6666aaaa6666aa0c77777c00000000000000000000000000000000000000000000000000000000
c0000000089aa9800dffffd00dffffd00d7f7fd00dffffd0aa7676aaaa7676aa0c7ccccc00000000000000000000000000000000000000000000000000000000
0000000c0897a9800fddddf00fddddf00fddddf00fddddf00a6666a0aa6666aa0c77cccc00000000000000000000000000000000000000000000000000000000
c00000000897a9800fddddf00fddddf00fddddf00fddddf000dddd00a0dddd0a0ccccccc00000000000000000000000000000000000000000000000000000000
0000000c008a980000dddd0000dddd0000dddd0000dddd00006dd600006dd60000ccccc000000000000000000000000000000000000000000000000000000000
c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000500000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000005550000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000007000000000000400000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55444440700000500000400000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05000007044444550000400000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000500000400000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000400000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007070000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000002141024204282060606064080060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000404040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000040000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000050000000000000000000404000000040000000004040000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000090000000a000000000000000404000000040000000000040400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000040000170000000400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000070000000000000000000404000000040000000000000400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000040400000000040400000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000404050404040000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000004000004040000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000404000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000400000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000400000404000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000400000400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000400000400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000404000000000400000400000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040404040404040400000404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0406000000040000070400070000060404040404040400000404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400040a04040a040b040a0404040f0404000000000400000400000000000004040000000004040404040400000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400040000000e0d000f000000000e0404000000000400000400000000000004040007000b0900000e0d0000040400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040c04000004040400040404040b040404000000000400000400000000000004040000000a040400000400000b0000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000000000000000004000000000004040000000004000004000000000000040400000000040000000d0004000004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040a04040b04040404040a040404040404040404040400000404040404040404040500000004000400040004000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000040000000000000000000000000000000d00000400000000000004040a04040404040400000004000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04000000060f0e07000000000000000000000000000d0000040000000000000f0f0000000007000404040b0404040c040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040000000c040404040404040411040404040404040411110404040404040404040404040b04040404040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000d0a0400000000040000000004040000000004000004000000000000040407000b090000040d000000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040a0d0f0404000000000e0018000004040000000004000004000000000000040400000a0404040404000404000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400040404040000000004000000000404000000000400000400000000000004040004000000000004000e00040400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000007000004000000000404000000000400000400000000000004040004040004040c04000400000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000004000000000404000000000400000400000000000004040004040000040504000400040400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040404040404040404040404040404040404040000000000000000000400000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004040404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011e00000e0340e031110240e021090340903109031090310e0340e031110240e02109034090310903109031070340703107024070210a0340a0310c0340c0310e0340e0310e0210e0210e0110e0110e0110e011
011e00001a5341a5311a5311a5311a5311a5311d5341d5311d5341d5311d5311d5312453424531245312453122534225311d5341d5311a5341a53122534225312153421531215312153121531215312153121531
011e00001c1151d1151a1251d1251c1151d1151a1251f1251c1151d1151a1251d1251c1151d1151a1251f1251c1151d1151a1251d1251c1151d1151a125211251c1151d1151a1251d1251c1151d1151a1251f125
013c00001c1151d115000001d1151c11521115000001f1151c1151d115000001d1151c11522115000001f1151c1151d115000001d1151c11521115000001f1151c1151d115000001d1151c11522115000001f115
013c000002054020310202102011020540203102021020110a0540a0310a0210a0110a0540a0310a0210a01102054020310202102011020540203102021020110a0540a0310a0210a0110a0540a0310a0210a011
013c00000161202612036120261203612036120361204612026120361201612016120161202612036120261203612036120361201612036120161202612026120361201612026120261202612036120261202612
011e000002034020310c024020210903409031090310903102034020310c0240202109034090310903109031070340703107024070210a0340a0310c0340c0310e0340e0310e0210e02102011020110201102011
011e00001c1151d115181251d1251c1151d11518125211251c1151d115181251d1251c1151d1151f1251d1251c1151d115181251d1251c1151d11518125211251c1151d115181251d1251c1151d1151f1251d125
011e0000185541855121554215511d5541d5311d5211d511185541855121554215511d5541d5311d5211d5111a5541a5311a5541a5311d5541d5511f5541f551215542154121531215211d5541d5311d5211d511
011e0000261451d135261451d135281451d135281451d135291451a135291451a1352d1451d1353014429135261001d10026100241001f10024100281001d1000000000000000000000000000000000000000000
010f00001555300000000000000021605000000000000000155530000000000155532060500000155530000015553000000000000000216050460000000000001555300000000001555321605000000000015553
010f000000500000000e55400500005000e55400500005000a5540a5410a5310a5210a5210a5110a5110a51100500005000755400000005000755400500005000c5540c5410c5310c5210c5210c5110c5110c511
010f000000000005001d55400500005001d5540050000500215542154121531215212454124531245212451100500005002155400500000002155400500005002655426541265312652122541225312252122511
011e0000245002450029524295112452424511245112451524500245002952429511285242851128511285152e5002e50029524295112d5242d5112d5112d515245002450029524295112b5242b5112b5112b511
011e0000261451d11526145241451d115241451d115261351a1151d125261451d115241451d115281452d14529145261152914528145261152814526115291451d115261252914526115241451f1152814524135
011e0000227442274122741227412474424741247412474126744267412674126741287442874128741287412974429741297411d74121744217412174121741247442474124741247411d7441c7441874415744
011e00002672426721267212672128724287212872128721297242972129721297212b7242b7212b7212b7212d7242d7212d7212172124724247212472124721287242872128721287212d7242b7242872424724
011e00000a0350a0350a0350a0350c0350c0350c0350c0350e0350e0350e0350e0351003510035100351003511035110351103511035150351503515035150351503515035150351503510035100351003510035
011000003c2333c200000000000000000000000000000000246000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c62400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003c02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002462524600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002862400000346451060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003c00001062500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000233651e365000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003072024751247551270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001e33425351233002036120341203312032100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005000000c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001476514763000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 01024344
03 01020044
03 03040544
03 06020849
00 41424344
03 0e110f10
00 12134344
00 14154344
00 16174344
00 18424344
00 19424344
00 1a424344
00 1b424344
00 1c424344

