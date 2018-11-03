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
	row_d = 0
	col_d = 0
end

function _update()
 get_move() 
 turn_timer -= 1
end

function _draw()
 cls()
 draw_player()
 draw_map()
 draw_arrows()
 debug()
end
-->8
--draw help
function draw_player()
 spr(3, p.x, p.y)
end

function draw_map()
 if friend.flight then
  draw_full_map()
 else 
  draw_partial_map()
 end
end

function draw_full_map()
 local x = cur_map_x-1
 local y = cur_map_y-1
 map(16*x,16*y,0,0,16,16)
end

function draw_partial_map()
 local x = cur_map_x-1
 local y = cur_map_y-1
 map(16*x+(p.x/8)-3, 16*y+(p.y/8)-3, p.x-24, p.y-24, 7, 7)
end

function draw_arrows()
 for arrow in all(arrow_array) do
  draw_arrow(arrow)
 end
end

function draw_arrow(arrow)
 local x = cur_map_x-1
 local y = cur_map_y-1
 spr(arrow.sprite, arrow.x, arrow.y)
 map(16*x+(arrow.x/8)-1, 16*y+(arrow.y/8)-1, arrow.x-8, arrow.y-8, 3, 3)
end

-->8
--player controller
function get_move()
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
 if can_move(p.x-8, p.y) then
  p.x -= 8
 end
end

function move_right()
 if can_move(p.x+8, p.y) then
  p.x += 8
 end
end

function move_up()
 if can_move(p.x, p.y-8) then
  p.y -= 8
 end
end

function move_down()
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
 create_arrow(x, y, direction)
end


function create_arrow(x, y, direction)
 arrow = {}
 arrow.x = x
 arrow.y = y
 arrow.direction = direction
 arrow.sprite = 2
 add(arrow_array, arrow)
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
 local map_x = cur_map_x-1
 local map_y = cur_map_y-1
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
	mset(p.x/8, p.y/8, 8)
	start = cur_map_x-1*16
	test = 'red'
	for row = 0, 16 do
		for col = 0, 16 do
			if get_bit(row*8,col*8,6) then
				wall_gone_red(row,col)
			elseif get_bit(row*8,col*8,7) then
				wall_back_blue(row,col)
			elseif mget(row*8,col*8,6) then
				mset(row,col,5)
			end
		end
	end
end

function press_blue()
	mset(p.x/8, p.y/8, 6)
	start = cur_map_x-1*16
	for row = 0, 16 do
		for col = 0, 16 do
			if get_bit(row*8,col*8,7) then
				wall_gone_blue(row,col)
			elseif get_bit(row*8,col*8,6) then
				wall_back_red(row,col)
			elseif mget(row*8,col*8,8) then
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
function debug()
 print(get_bit(p.x,p.y,5), 0, 0)
 print(row_d, 70, 0)
  print(col_d, 70, 10)
  print(test, 0, 10)
end
__gfx__
000000006004400600000000000099005555555500000000000000000000000000000000585858585c5c5c5c00000000066f0000044444000044444008080808
00000000600440060000400000999900500505050cccccc00cccccc0088888800888888080080805c00c0c0544446554000ff00004f7470660747f4080000000
00700700601111060000044009900990555555550c1111c00cccccc00822228008888880588888885ccccccc4ff5555047f5f55004ffff0660ffff4000000008
00077000601111064444404409099090500505050c1111c00cccccc0082222800888888080080805c00c0c0547f5555044f55554045555ffff55554080000000
00077000601111060000004409000990555555550c1111c00cccccc00822228008888880588888885ccccccc44f5555447f5555006555ff00ff5556000000008
00700700600000060000444009999990500505050c1111c00cccccc0082222800888888080080805c00c0c0547f5f5504ff55550055555000055555080000000
00000000600000060004400009999900500505050cccccc00cccccc0088888800888888050080808500c0c0c000ff00044446554055555000055555000000008
00000000666666660000000000000000555555550000000000000000000000000000000085858585c5c5c5c5066f000000000000040040000004004080808080
0c0c0c0c000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000008980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c008998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00000000899a9800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c089a7a980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000089a7a980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c089a0a980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0899000980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000002141024204282060606064080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000004040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000050000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000090000000a000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000070000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000015000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000004040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040404040404040400000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000000000000000000000400000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040404040004040400000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000004040400000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040004000404040400040400000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040004000000000400000004040000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040004040004000400040000040000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040004040004000400040004040000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0400000000000000000000000000000400000000000000000000000000000004040000000000000000040000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
