##########################################################################################################################################
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Richard Soma, 1006670201
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 5
# 
# Which approved additional features have been implemented?
# 1. Display the number of lives remaining.
# 2. After final player death, display game over/retry screen. Restart the game if the “retry” option is chosen.
# 3. Dynamic increase in difficulty (speed) as game progresses.
# 4. Have objects in different rows move at different speeds.
# 5. Add a third row in each of the water and road sections.
# 6. Add extra random hazards (alligators in the goal areas).
# 7. Display the player’s score at the top of the screen.
#
# Additional information that the TA may need to know:
# - The number of frogs on the top left corner of the screen is the number of frogs/lives the player has.
# - The number of red hearts on the top right corner of the screen is the player's score.
# - Every frog that reaches the goal area immediately becomes an alligator (except when the player wins with 3 hearts).
# - The more hearts (higher score) the player has, the faster the objects move.
# - Speed-running the game: a6w6d1w6a2w12, a2w15w3w6, d4w3a4w9a5w3w3w3w3.
##########################################################################################################################################
.data
	# display locations
	displayAddress:	.word 0x10008000 # origin
	frogPos:	.word 0x10008EC0 # the top left location of the frog
	row1CarPos:	.space 12 # the top left locations of the first row of cars
	row2CarPos:	.space 12 # the top left locations of the second row of cars
	row3CarPos:	.space 12 # the top left locations of the third row of cars
	row1LogPos:	.space 12 # the top left locations of the first row of logs
	row2LogPos:	.space 12 # the top left locations of the second row of logs
	row3LogPos:	.space 12 # the top left locations of the third row of logs
	aliPos:		.space 20 # the top left locations of alligators
	
	# movement speeds (counters, number of frames before moving 1 pixel, the lower the faster!)
	row1CarSp:	.word 0 # the speed of the first row of cars
	row2CarSp:	.word 0 # the speed of the second row of cars
	row3CarSp:	.word 0 # the speed of the third row of cars
	row1LogSp:	.word 0 # the speed of the first row of logs
	row2LogSp:	.word 0 # the speed of the second row of logs
	row3LogSp:	.word 0 # the speed of the third row of logs
	
	row1CarCt:	.word 0 # the counter for the first row of cars
	row2CarCt:	.word 0 # the counter for the second row of cars
	row3CarCt:	.word 0 # the counter for the third row of cars
	row1LogCt:	.word 0 # the counter for the first row of logs
	row2LogCt:	.word 0 # the counter for the second row of logs
	row3LogCt:	.word 0 # the counter for the third row of logs
	
	# sizes (in # of pixels)
	screenSize:	.word 32 # the side length of the screen
	rectHeight:	.word 3 # the vertical height of a car/log
	logLength:	.word 6 # the horizontal length of a log
	carLength:	.word 3 # the horizontal length of a car
	
	# colors
	red:		.word 0xff0000 # cars & hearts
	green:		.word 0x00ff00 # grass
	blue:		.word 0x0000ff # river
	magenta:	.word 0xff00ff # alligators (mutated frogs)
	orange:		.word 0xff7f00 # middle safe region
	darkGreen:	.word 0x007f00 # frog
	brown:		.word 0x963232 # logs
	grey:		.word 0x7f7f7f # street
	black:		.word 0x000000 # text
	
	# other stuff
	aliNum:		.word 2 # number of alligators
	lives:		.word 3 # number of frogs the player has
	score:		.word 0 # player's score

##########################################################################################################################################
.text
Initialize:	lw $s0, displayAddress # s0 ALWAYS = base address for display
		
		# reset aliNum, lives, and score
		addiu $t1, $zero, 2 # t1 = 2
		sw $t1, aliNum # aliNum = 2
		addiu $t1, $zero, 3 # t1 = 3
		sw $t1, lives # lives = 3
		sw $zero, score # score = 0
		
		# initialize the position of the frog
		addiu $t1, $zero, 0x10008EC0
		sw $t1, frogPos
		
		# initialize the positions of the logs on row 3
		addiu $t1, $s0, 1028 # t1 = the pos of the first log on row 3, offset = 128*8+4*1
		sw $t1, row3LogPos+0 # store the pos of the first log on row 3
		addiu $t1, $s0, 1072 # t1 = the pos of the second log on row 3, offset = 128*8+4*12
		sw $t1, row3LogPos+4 # store the pos of the second log on row 3
		addiu $t1, $s0, 1120 # t1 = the pos of the third log on row 3, offset = 128*8+4*24
		sw $t1, row3LogPos+8 # store the pos of the third log on row 3
		
		# initialize the positions of the logs on row 2
		addiu $t1, $s0, 1428 # t1 = the pos of the first log on row 2, offset = 128*11+4*5
		sw $t1, row2LogPos+0 # store the pos of the first log on row 2
		addiu $t1, $s0, 1472 # t1 = the pos of the second log on row 2, offset = 128*11+4*16
		sw $t1, row2LogPos+4 # store the pos of the second log on row 2
		addiu $t1, $s0, 1516 # t1 = the pos of the third log on row 2, offset = 128*11+4*27
		sw $t1, row2LogPos+8 # store the pos of the third log on row 2
		
		# initialize the positions of the logs on row 1
		addiu $t1, $s0, 1804 # t1 = the pos of the first log on row 1, offset = 128*14+4*3
		sw $t1, row1LogPos+0 # store the pos of the first log on row 1
		addiu $t1, $s0, 1852 # t1 = the pos of the second log on row 1, offset = 128*14+4*15
		sw $t1, row1LogPos+4 # store the pos of the second log on row 1
		addiu $t1, $s0, 1888 # t1 = the pos of the third log on row 1, offset = 128*14+4*24
		sw $t1, row1LogPos+8 # store the pos of the third log on row 1
		
		# initialize the positions of the cars on row 3
		addiu $t1, $s0, 2572 # t1 = the pos of the first car on row 3, offset = 128*20+4*3
		sw $t1, row3CarPos+0 # store the pos of the first car on row 3
		addiu $t1, $s0, 2608 # t1 = the pos of the second car on row 3, offset = 128*20+4*12
		sw $t1, row3CarPos+4 # store the pos of the second car on row 3
		addiu $t1, $s0, 2656 # t1 = the pos of the third car on row 3, offset = 128*20+4*24
		sw $t1, row3CarPos+8 # store the pos of the third car on row 3
		
		# initialize the positions of the cars on row 2
		addiu $t1, $s0, 2944 # t1 = the pos of the first car on row 2, offset = 128*23+4*0
		sw $t1, row2CarPos+0 # store the pos of the first car on row 2
		addiu $t1, $s0, 2996 # t1 = the pos of the second car on row 2, offset = 128*23+4*13
		sw $t1, row2CarPos+4 # store the pos of the second car on row 2
		addiu $t1, $s0, 3036 # t1 = the pos of the third car on row 2, offset = 128*23+4*23
		sw $t1, row2CarPos+8 # store the pos of the third car on row 2
		
		# initialize the positions of the cars on row 1
		addiu $t1, $s0, 3356 # t1 = the pos of the first car on row 1, offset = 128*26+4*7
		sw $t1, row1CarPos+0 # store the pos of the first car on row 1
		addiu $t1, $s0, 3400 # t1 = the pos of the second car on row 1, offset = 128*26+4*18
		sw $t1, row1CarPos+4 # store the pos of the second car on row 1
		addiu $t1, $s0, 3444 # t1 = the pos of the third car on row 1, offset = 128*26+4*29
		sw $t1, row1CarPos+8 # store the pos of the third car on row 1
		
		# initialize the positions of the alligators
		addiu $t1, $s0, 652 # t1 = the pos of the first alligators, offset = 128*5+4*3
		sw $t1, aliPos+0 # store the pos of the first alligators
		addiu $t1, $s0, 744 # t1 = the pos of the second alligators, offset = 128*5+4*26
		sw $t1, aliPos+4 # store the pos of the second alligators
		
		# initialize the speeds of objects
		addiu $t1, $zero, 30
		sw $t1, row3LogSp # store the speed of the logs on row 3
		sw $t1, row3LogCt # store the speed of the logs on row 3
		addiu $t1, $zero, 20
		sw $t1, row2LogSp # store the speed of the logs on row 2
		sw $t1, row2LogCt # store the speed of the logs on row 2
		addiu $t1, $zero, 40
		sw $t1, row1LogSp # store the speed of the logs on row 1
		sw $t1, row1LogCt # store the speed of the logs on row 1
		addiu $t1, $zero, 20
		sw $t1, row3CarSp # store the speed of the cars on row 3
		sw $t1, row3CarCt # store the speed of the cars on row 3
		addiu $t1, $zero, 40
		sw $t1, row2CarSp # store the speed of the cars on row 2
		sw $t1, row2CarCt # store the speed of the cars on row 2
		addiu $t1, $zero, 30
		sw $t1, row1CarSp # store the speed of the cars on row 1
		sw $t1, row1CarCt # store the speed of the cars on row 1

Mainloop:	# end the loop if lives = 0
		lw $t0, lives # t0 = lives
		beq $t0, $zero, Endgame # if lives = 0, then jump to endgame

UpdatePos:	# update the pos of logs on row 3
		lw $s1, row3LogCt # s1 = row3LogCt
		addi $s1, $s1, -1 # s1 -= 1
		sw $s1, row3LogCt # row3LogCt -= 1
		bne $s1, $zero, r2l # if row3LogCt == 0, then move the logs
		lw $s2, row3LogSp # s2 = row3LogSp
		sw $s2, row3LogCt # row3LogCt = row3LogSp
		addiu $s1, $zero, 4 # s1 = 4 = speed * 4
		# first log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row3LogPos+0  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row3LogPos+0
		# second log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row3LogPos+4  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row3LogPos+4
		# third log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row3LogPos+8  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row3LogPos+8
		
	r2l:	# update the pos of logs on row 2
		lw $s1, row2LogCt # s1 = row2LogCt
		addi $s1, $s1, -1 # s1 -= 1
		sw $s1, row2LogCt # row2LogCt -= 1
		bne $s1, $zero, r1l # if row2LogCt == 0, then move the logs
		lw $s2, row2LogSp # s2 = row2LogSp
		sw $s2, row2LogCt # row2LogCt = row2LogSp
		addiu $s1, $zero, 4 # s1 = 4 = speed * 4
		# first log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row2LogPos+0  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row2LogPos+0
		# second log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row2LogPos+4  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row2LogPos+4
		# third log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row2LogPos+8  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row2LogPos+8
		
	r1l:	# update the pos of logs on row 1
		lw $s1, row1LogCt # s1 = row1LogCt
		addi $s1, $s1, -1 # s1 -= 1
		sw $s1, row1LogCt # row1LogCt -= 1
		bne $s1, $zero, r3c # if row1LogCt == 0, then move the logs
		lw $s2, row1LogSp # s2 = row1LogSp
		sw $s2, row1LogCt # row1LogCt = row1LogSp
		addiu $s1, $zero, 4 # s1 = 4 = speed * 4
		# first log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row1LogPos+0  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row1LogPos+0
		# second log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row1LogPos+4  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row1LogPos+4
		# third log
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row1LogPos+8  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row1LogPos+8
		
	r3c:	# update the pos of cars on row 3
		lw $s1, row3CarCt # s1 = row3CarCt
		addi $s1, $s1, -1 # s1 -= 1
		sw $s1, row3CarCt # row3CarCt -= 1
		bne $s1, $zero, r2c # if row3CarCt == 0, then move the cars
		lw $s2, row3CarSp # s2 = row3CarSp
		sw $s2, row3CarCt # row3CarCt = row3CarSp
		addiu $s1, $zero, 4 # s1 = 4 = speed * 4
		# first car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row3CarPos+0  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row3CarPos+0
		# second car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row3CarPos+4  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row3CarPos+4
		# third car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row3CarPos+8  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row3CarPos+8
		
	r2c:	# update the pos of cars on row 2
		lw $s1, row2CarCt # s1 = row2CarCt
		addi $s1, $s1, -1 # s1 -= 1
		sw $s1, row2CarCt # row2CarCt -= 1
		bne $s1, $zero, r1c # if row2CarCt == 0, then move the cars
		lw $s2, row2CarSp # s2 = row2CarSp
		sw $s2, row2CarCt # row2CarCt = row2CarSp
		addiu $s1, $zero, 4 # s1 = 4 = speed * 4
		# first car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row2CarPos+0  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row2CarPos+0
		# second car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row2CarPos+4  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row2CarPos+4
		# third car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row2CarPos+8  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectRight # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row2CarPos+8
		
	r1c:	# update the pos of cars on row 1
		lw $s1, row1CarCt # s1 = row1CarCt
		addi $s1, $s1, -1 # s1 -= 1
		sw $s1, row1CarCt # row1CarCt -= 1
		bne $s1, $zero, DrawBackground # if row1CarCt == 0, then move the cars
		lw $s2, row1CarSp # s2 = row1CarSp
		sw $s2, row1CarCt # row1CarCt = row1CarSp
		addiu $s1, $zero, 4 # s1 = 4 = speed * 4
		# first car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row1CarPos+0  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row1CarPos+0
		# second car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row1CarPos+4  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row1CarPos+4
		# third car
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push speed * 4 to stack
		lw $s2, row1CarPos+8  # s2 = top left pos
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push top left pos to stack
		jal MoveRectLeft # update pos
		lw $s3, 0($sp) # s3 = updated top left pos
		addiu $sp, $sp, 4
		sw $s3, row1CarPos+8

DrawBackground:	# draw the starting area
		lw $t1, green # t1 = green
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push color to stack
		lw $t1, screenSize # t1 = horizontal length = screen size
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push horizontal length to stack
		addiu $t1, $zero 3 # t1 = vertical height = 3
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push vertical height to stack
		addiu $t1, $s0, 3712  # t1 = top left pos, offset = 128*29
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		# draw the street
		lw $t1, grey # t1 = grey
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push color to stack
		lw $t1, screenSize # t1 = horizontal length = screen size
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push horizontal length to stack
		addiu $t1, $zero 9 # t1 = vertical height = 9
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push vertical height to stack
		addiu $t1, $s0, 2560  # t1 = top left pos, offset = 128*20
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		# draw the middle safe region
		lw $t1, orange # t1 = orange
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push color to stack
		lw $t1, screenSize # t1 = horizontal length = screen size
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push horizontal length to stack
		addiu $t1, $zero 3 # t1 = vertical height = 3
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push vertical height to stack
		addiu $t1, $s0, 2176  # t1 = top left pos, offset = 128*17
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		# draw the river
		lw $t1, blue # t1 = blue
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push color to stack
		lw $t1, screenSize # t1 = horizontal length = screen size
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push horizontal length to stack
		addiu $t1, $zero 9 # t1 = vertical height = 9
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push vertical height to stack
		addiu $t1, $s0, 1024  # t1 = top left pos, offset = 128*8
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		# draw the goal area
		lw $t1, green # t1 = green
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push color to stack
		lw $t1, screenSize # t1 = horizontal length = screen size
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push horizontal length to stack
		addiu $t1, $zero 8 # t1 = vertical height = 8
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push vertical height to stack
		addi $sp, $sp, -4
		sw $s0, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect

DrawObjects:	lw $s3, rectHeight # s3 = vertical height = rect height
		
		# draw the 9 logs
		lw $s1, brown # s1 = brown
		lw $s2, logLength # s2 = horizontal length = log length
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row3LogPos+0  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row3LogPos+4  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row3LogPos+8  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row2LogPos+0  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row2LogPos+4  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row2LogPos+8  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row1LogPos+0  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row1LogPos+4  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row1LogPos+8  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		# draw the 9 cars
		lw $s1, red # s1 = red
		lw $s2, carLength # s2 = horizontal length = car length
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row3CarPos+0  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row3CarPos+4  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row3CarPos+8  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row2CarPos+0  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row2CarPos+4  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row2CarPos+8  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row1CarPos+0  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row1CarPos+4  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		addi $sp, $sp, -4
		sw $s1, 0($sp) # push color to stack
		addi $sp, $sp, -4
		sw $s2, 0($sp) # push horizontal length to stack
		addi $sp, $sp, -4
		sw $s3, 0($sp) # push vertical height to stack
		lw $t1, row1CarPos+8  # t1 = top left pos
		addi $sp, $sp, -4
		sw $t1, 0($sp) # push top left pos to stack
		jal DrawRect # draw the rect
		
		# draw the alligators
		lw $s1, magenta # s1 = magenta
		lw $s2, aliNum # s2 = number of alligators
		addiu $t1, $zero, 0 # t1 = i = 0
		addiu $t2, $zero, 0 # t2 = offset = 0
	starta:	beq $t1, $s2, Collision # finish loop if i = number of alligators
		lw $t3, aliPos($t2)
		sw $s1, 0($t3)
		sw $s1, 4($t3)
		sw $s1, 8($t3)
		sw $s1, 132($t3)
		sw $s1, 256($t3)
		sw $s1, 264($t3)
	upda:	addiu $t1, $t1, 1 # i++
		addiu $t2, $t2, 4 # offset += 4
		j starta # jump back to loop

Collision:	# check for collisions
		lw $t1, frogPos # t1 = current position of the frog
		lw $t2, 0($t1) # t2 = color of the top left corner of the frog
		lw $t3, 8($t1) # t3 = color of the top right corner of the frog
		lw $t4, 256($t1) # t4 = color of the bottom left corner of the frog
		lw $t5, 264($t1) # t5 = color of the bottom right corner of the frog
		
		# if touching a car, dead
		lw $t6, red # t6 = the color of the cars
		beq $t2, $t6, dead
		beq $t3, $t6, dead
		beq $t4, $t6, dead
		beq $t5, $t6, dead
		
		# if touching the river, dead
		lw $t6, blue # t6 = the color of the river
		beq $t2, $t6, dead
		beq $t3, $t6, dead
		beq $t4, $t6, dead
		beq $t5, $t6, dead
		
		# if touching an alligators, dead
		lw $t6, magenta # t6 = the color of the alligators
		beq $t2, $t6, dead
		beq $t3, $t6, dead
		
		# if whole frog in goal area, win
		addiu $t7, $s0, 3708 # t7 = bottom right corner of the street, offset = 128*29-4
		bge $t7, $t1, cwin # if the frog is not completely inside the starting area (t7 > t1), proceed to check if winning
		j clog
	cwin:	lw $t6, green # t6 = the color of the goal area
		bne $t2, $t6, clog
		bne $t3, $t6, clog
		bne $t4, $t6, clog
		bne $t5, $t6, clog
		# increase score
		lw $t7, score # t7 = score
		addiu $t7, $t7, 1 # t7 += 1
		sw $t7, score # score += 1
		# turn frog into alligators
		lw $t7, aliNum # t7 = aliNum
		sll $t6, $t7, 2 # t6 = t7 * 4 = offset for new pos
		addiu $t7, $t7, 1 # t7 += 1
		sw $t7, aliNum # aliNum += 1
		sw $t1, aliPos($t6) # append current frog pos into aliPos
		# increase the speed of objects
		lw $t7, row3LogSp # t7 = row3LogSp
		addi $t7, $t7, -9 # t7 -= 8
		sw $t7, row3LogSp # row3LogSp -= 8
		lw $t7, row2LogSp # t7 = row2LogSp
		addi $t7, $t7, -6 # t7 -= 8
		sw $t7, row2LogSp # row2LogSp -= 8
		lw $t7, row1LogSp # t7 = row1LogSp
		addi $t7, $t7, -12 # t7 -= 8
		sw $t7, row1LogSp # row1LogSp -= 8
		lw $t7, row3CarSp # t7 = row3CarSp
		addi $t7, $t7, -6 # t7 -= 8
		sw $t7, row3CarSp # row3CarSp -= 8
		lw $t7, row2CarSp # t7 = row2CarSp
		addi $t7, $t7, -12 # t7 -= 8
		sw $t7, row2CarSp # row2CarSp -= 8
		lw $t7, row1CarSp # t7 = row1CarSp
		addi $t7, $t7, -9 # t7 -= 8
		sw $t7, row1CarSp # row1CarSp -= 8
		# you won, but did you really win?
		j dead
	
	clog:	# if whole frog on log (in water position and top left = log start), then move with the log (unless touching corner)
		addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		subu $t2, $t1, $s0 # t2 = t1 - s0 = offset of current pos
		divu $t2, $t0 # t2 / t0 = offset / 128, so lo = offset // 128
		mflo $t3 # t3 = offset // 128
		
	crow3:	bne $t3, 8, crow2 # if offset // 128 == 8 <=> frog on a whole log in row 3, then move with the log
		lw $t2, row3LogCt # t2 = row3LogCt
		lw $t3, row3LogSp # t3 = row3LogSp
		bne $t2, $t3, Keyboard # if t2 == t3, then try moving the frog to the right
		j mvr
	crow2:	bne $t3, 11, crow1 # if offset // 128 == 11 <=> frog on a whole log in row 2, then move with the log
		lw $t2, row2LogCt # t2 = row2LogCt
		lw $t3, row2LogSp # t3 = row2LogSp
		bne $t2, $t3, Keyboard # if t2 == t3, then try moving the frog to the left
		j mvl
	crow1:	bne $t3, 14, Keyboard # if offset // 128 == 14 <=> frog on a whole log in row 1, then move with the log	
		lw $t2, row1LogCt # t2 = row1LogCt
		lw $t3, row1LogSp # t3 = row1LogSp
		bne $t2, $t3, Keyboard # if t2 == t3, then try moving the frog to the right
		j mvr
	
	mvr:	addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		addiu $t2, $t1, 12 # t2 = t1 + 12 = the next pixel on the right of the frog
		subu $t2, $t2, $s0 # t2 = t2 - s0 = offset of that pixel
		divu $t2, $t0 # t2 / t0 = offset / 128, so hi = offset % 128
		mfhi $t2 # t2 = offset % 128
		bne $zero, $t2, r # if offset % 128 != 0, allow the frog to move right
		j Keyboard
		r:	addiu $t1, $t1, 4
			sw $t1, frogPos
			j Keyboard
	
	mvl:	addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		subu $t2, $t1, $s0 # t2 = t1 - s0 = offset of current frog pos
		divu $t2, $t0 # t2 / t0 = offset / 128, so hi = offset % 128
		mfhi $t2 # t2 = offset % 128
		bne $zero, $t2, l # if offset % 128 != 0, allow the frog to move left
		j Keyboard
		l:	addi $t1, $t1, -4
			sw $t1, frogPos
			j Keyboard
	
	dead:	# reduce lives
		lw $t1, lives # t1 = lives
		addi $t1, $t1, -1 # t1 -= 1
		sw $t1, lives # lives -= 1
		# if score != 3, re-initialize the position of the frog
		lw $t1, score # t1 = score
		beq $t1, 3, DrawFrog # if score = 3, then keep the frog here
		addiu $t1, $zero, 0x10008EC0
		sw $t1, frogPos
		j DrawFrog

Keyboard:	# check if any key has been pressed
		lw $t1, 0xffff0000
		beq $t1, 1, input
		j DrawFrog
	
	input:	lw $t1, frogPos # t1 = frog's current pos
		lw $t2, 0xffff0004
		beq $t2, 0x77, W
		beq $t2, 0x61, A
		beq $t2, 0x73, S
		beq $t2, 0x64, D
		beq $t2, 0x71, Exit # quit the game
		beq $t2, 0x72, Initialize # restart the game
		j DrawFrog
	
	W:	# move forward by 1 pixel
		addi $t1, $t1, -128
		sw $t1, frogPos
		j DrawFrog
	
	A:	# move left by 1 pixel
		addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		subu $t2, $t1, $s0 # t2 = t1 - s0 = offset of current frog pos
		divu $t2, $t0 # t2 / t0 = offset / 128, so hi = offset % 128
		mfhi $t2 # t2 = offset % 128
		bne $zero, $t2, left # if offset % 128 != 0, allow the frog to move left
		j DrawFrog
		left:	addi $t1, $t1, -4
			sw $t1, frogPos
			j DrawFrog
	
	S:	# move backward by 1 pixel
		addiu $t2, $s0, 3708 # t2 = bottom right corner of the street, offset = 128*29-4
		bge $t2, $t1, back # if the frog is not completely inside the starting area (t2 > t1), allow it to move back
		j DrawFrog
		back:	addiu $t1, $t1, 128
			sw $t1, frogPos
			j DrawFrog
	
	D:	# move right by 1 pixel
		addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		addiu $t2, $t1, 12 # t2 = t1 + 12 = the next pixel on the right of the frog
		subu $t2, $t2, $s0 # t2 = t2 - s0 = offset of that pixel
		divu $t2, $t0 # t2 / t0 = offset / 128, so hi = offset % 128
		mfhi $t2 # t2 = offset % 128
		bne $zero, $t2, right # if offset % 128 != 0, allow the frog to move right
		j DrawFrog
		right:	addiu $t1, $t1, 4
			sw $t1, frogPos
			j DrawFrog

DrawFrog:	lw $t0, lives # t0 = lives
		lw $t1, frogPos # t1 = current pos of the frog
		lw $t2, darkGreen # t2 = the color of the frog
		sw $t2, 0($t1)
		sw $t2, 8($t1)
		sw $t2, 132($t1)
		sw $t2, 256($t1)
		sw $t2, 260($t1)
		sw $t2, 264($t1)

DrawFrogs:	lw $t1, lives # t1 = lives
		addiu $t2, $zero, 0 # t2 = i = 0
		lw $t3, darkGreen # t3 = dark green
		lw $t4, displayAddress # t4 = top left corner of the screen
	startf:	beq $t2, $t1, DrawHearts # finish loop if i = lives
		# draw a frog at t4
		sw $t3, 0($t4)
		sw $t3, 8($t4)
		sw $t3, 132($t4)
		sw $t3, 256($t4)
		sw $t3, 260($t4)
		sw $t3, 264($t4)
		addiu $t4, $t4, 12 # t4 += 12
	updf:	addiu $t2, $t2, 1 # i++
		j startf # jump back to loop

DrawHearts:	lw $t1, score # t1 = score
		addiu $t2, $zero, 0 # t2 = i = 0
		lw $t3, red # t3 = red
		lw $t4, displayAddress # t4 = top left corner of the screen
		addiu $t4, $t4, 116 # t4 = top left pos of first heart
	starth:	beq $t2, $t1, Sleep # finish loop if i = score
		# draw a heart at t4
		sw $t3, 0($t4)
		sw $t3, 8($t4)
		sw $t3, 128($t4)
		sw $t3, 132($t4)
		sw $t3, 136($t4)
		sw $t3, 260($t4)
		addi $t4, $t4, -12 # t4 -= 12
	updh:	addiu $t2, $t2, 1 # i++
		j starth # jump back to loop

Sleep:		li $v0, 32
 		li $a0, 16 # sleep for the specified number of milliseconds
 		syscall
 		j Mainloop # go back to mainloop

Endgame:	# draw GG
		lw $t1, black # t1 = black
		sw $t1, 48($s0)
		sw $t1, 52($s0)
		sw $t1, 56($s0)
		sw $t1, 72($s0)
		sw $t1, 76($s0)
		sw $t1, 80($s0)
		sw $t1, 172($s0)
		sw $t1, 196($s0)
		sw $t1, 300($s0)
		sw $t1, 308($s0)
		sw $t1, 312($s0)
		sw $t1, 324($s0)
		sw $t1, 332($s0)
		sw $t1, 336($s0)
		sw $t1, 428($s0)
		sw $t1, 440($s0)
		sw $t1, 452($s0)
		sw $t1, 464($s0)
		sw $t1, 556($s0)
		sw $t1, 560($s0)
		sw $t1, 564($s0)
		sw $t1, 568($s0)
		sw $t1, 580($s0)
		sw $t1, 584($s0)
		sw $t1, 588($s0)
		sw $t1, 592($s0)

		# check keyboard for restart or quit
		lw $t1, 0xffff0000
		beq $t1, 1, input2
		j Endgame # if no key is getting pressed, keep waiting
	input2:	lw $t2, 0xffff0004
		beq $t2, 0x71, Exit # quit the game
		beq $t2, 0x72, Initialize # restart the game
		j Endgame # if neither q nor r was pressed, keep waiting

Exit:	li $v0, 10 # terminate the program gracefully
 	syscall
##########################################################################################################################################
# Draw the rectangle and wrap it around the screen if necessary
# Input: top left pos, vertical height, horizontal length, color
# Output: void
# Precondition: the rectangle must not be forced to wrap around VERTICALLY
DrawRect:	# pop input parameters from stack
		lw $t1, 0($sp) # t1 = top left pos
		addiu  $sp, $sp, 4
		lw $t2, 0($sp) # t2 = vertical height
		addiu $sp, $sp, 4
		lw $t3, 0($sp) # t3 = horizontal length
		addiu $sp, $sp, 4
		lw $t4, 0($sp) # t4 = color
		addiu $sp, $sp, 4

		# nested loops
		addiu $t5, $zero, 0 # t5 = i = 0
	start1:	beq $t5, $t2, exit1 # finish loop if i = vertical height
		addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		addiu $t6, $zero, 0 # t6 = j = 0
		start2:	beq $t6, $t3, exit2 # finish loop if j = horizontal length
			sw $t4, 0($t1) # draw a pixel
			addiu $t1, $t1, 4 # t1 += 4
			# check if we need to wrap around, if so then current pos -= 128
			subu $t7, $t1, $s0 # t7 = t1 - s0 = offset of current pos
			divu $t7, $t0 # t7 / t0 = offset / 128, so hi = offset % 128
			mfhi $t7 # t7 = offset % 128
			bne $zero, $t7, upd2 # enter if block if offset % 128 == 0
				addi $t1, $t1, -128 # t1 -= 128
		upd2:	addiu $t6, $t6, 1 # j++
			j start2 # jump back to inner loop
		exit2:	sll $t6, $t3, 2 # t6 = horizontal length * 4
			# check if we need to wrap around, if so then current pos += 128
			subu $t7, $t1, $s0 # t7 = t1 - s0 = offset of current pos
			divu $t7, $t0 # t7 / t0 = offset / 128, so hi = offset % 128
			mfhi $t0 # t0 = offset % 128
			sub $t7, $t6, $t0 # t7 = t6 - t0 = horizontal length * 4 - offset % 128
			bgtz $t7, if # enter if block if t7 > 0, which means offset % 128 < horizontal length * 4
			j normal # finish if block
			if:	addiu $t1, $t1, 128 # t1 += 128
		normal:	subu $t1, $t1, $t6 # t1 = t1 - t6
			addiu $t1, $t1, 128 # t1 += 128, ready for next row
	upd1:	addiu $t5, $t5, 1 # i++
		j start1 # jump back to outer loop
	exit1:	jr $ra # finish

# Move the top left pos rectangle towards the right and wrap it around the screen if necessary
# Input: top left pos, horizontal displacement = speed * 4
# Output: updated top left pos
# Precondition:
MoveRectRight:	# pop input parameters from stack
		lw $t1, 0($sp) # t1 = top left pos
		addiu  $sp, $sp, 4
		lw $t2, 0($sp) # t2 = speed * 4
		addiu $sp, $sp, 4
		
		# increment t1 and check if we need to wrap around
		addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		addu $t1, $t1, $t2 # t1 = t1 + speed * 4
		subu $t3, $t1, $s0 # t3 = t1 - s0 = offset of current pos
		divu $t3, $t0 # t3 / t0 = offset / 128, so hi = offset % 128
		mfhi $t4 # t4 = offset % 128
		sub $t5, $t2, $t4 # t5 = t2 - t4 = speed * 4 - offset % 128
		bgtz $t5, if1 # enter if block if t5 > 0, which means offset % 128 < speed * 4
		j done1 # finish if block
		if1:	addi $t1, $t1, -128 # t1 -= 128
		done1:	addi $sp, $sp, -4
			sw $t1, 0($sp) # push updated t1 to stack
			jr $ra # finish

# Move the top left pos rectangle towards the left and wrap it around the screen if necessary
# Input: top left pos, horizontal displacement = speed * 4
# Output: updated top left pos
# Precondition:
MoveRectLeft:	# pop input parameters from stack
		lw $t1, 0($sp) # t1 = top left pos
		addiu  $sp, $sp, 4
		lw $t2, 0($sp) # t2 = speed * 4
		addiu $sp, $sp, 4
		
		# decrement t1 and check if we need to wrap around
		addiu $t0, $zero, 128 # t0 = 128, acts as the divisor when dealing with wrap around
		subu $t3, $t1, $s0 # t3 = t1 - s0 = offset of current pos
		divu $t3, $t0 # t3 / t0 = offset / 128, so hi = offset % 128
		mfhi $t4 # t4 = offset % 128
		sub $t5, $t2, $t4 # t5 = t2 - t4 = speed * 4 - offset % 128
		bgtz $t5, if2 # enter if block if t5 > 0, which means offset % 128 < speed * 4
		j done2 # finish if block
		if2:	addiu $t1, $t1, 128 # t1 += 128
		done2:	subu $t1, $t1, $t2 # t1 = t1 - speed * 4
			addi $sp, $sp, -4
			sw $t1, 0($sp) # push updated t1 to stack
			jr $ra # finish
##########################################################################################################################################
