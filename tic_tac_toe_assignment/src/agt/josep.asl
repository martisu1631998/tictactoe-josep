/*

Implementation of our Tic-Tac-Toe player.

When the agent is started it must first perform a 'sayHello' action.
Once all agents have done this, the game or tournament starts.

Each turn the agent will observe the following percepts:

- symbol(x) or symbol(o) 
	This indicates which symbol this agent should use to mark the cells. It will be the same in every turn.

- a number of marks:  e.g. mark(0,0,x) , mark(0,1,o) ,  mark(2,2,x)
  this indicates which cells have been marked with a 'x' or an 'o'. 
  Of course, in the first turn no cell will be marked yet, so there will be no such percept.

- round(Z)
	Indicates in which round of the game we are. 
	Since this will be changing each round, it can be used by the agent as a trigger to start the plan to determine
	its next move.


Furthermore, the agent may also observe the following:

- next 
	This means that it is this agent's turn.
  
- winner(x) or winner(o)
	If the game is over and did not end in a draw. Indicates which player won.
	
- end 
	If the game is finished.
	
- After observing 'end' the agent must perform the action 'confirmEnd'.

To mark a cell, use the 'play' action. For example if you perform the action play(1,1). 
Then the cell with coordinates (1,1) will be marked with your symbol. 
This action will fail if that cell is already marked.

*/



/* Initial beliefs and rules */


// First, define a 'cell' to be a pair of numbers, between 0 and 2. i.e. (0,0) , (0,1), (0,2) ... (2,2)
isCoordinate(0).
isCoordinate(1).
isCoordinate(2).
isCell(X,Y) :- isCoordinate(X) & isCoordinate(Y).

// Define the three possible states of each cell
available(X,Y) :- isCell(X,Y) & not mark(X,Y,_).
my_piece(X,Y) :- isCell(X,Y) & mark(X,Y,S) & symbol(S).
opponent_piece(X,Y) :- isCell(X,Y) & not available(X,Y) & not my_piece(X,Y).

// Check if two cells have the same state
coincide(H,O,L,A) :- (my_piece(H,O) & my_piece(L,A)) | (opponent_piece(H,O) & opponent_piece(L,A)).

/* Returns true if a cell is in a critical position, where the agent can either win or lose in the next turn 
It checks all the valid three-in-a-row structures */
// Horizontal row
horizontal(X,Y) :- available(X,Y) & coincide(X,Y+1,X,Y+2).
horizontal(X,Y) :- available(X,Y) & coincide(X,Y-1,X,Y-2).
horizontal(X,Y) :- available(X,Y) & coincide(X,Y+1,X,Y-1).

// Vertical row
vertical(X,Y) :- available(X,Y) & coincide(X+1,Y,X+2,Y).
vertical(X,Y) :- available(X,Y) & coincide(X-1,Y,X-2,Y).
vertical(X,Y) :- available(X,Y) & coincide(X+1,Y,X-1,Y).

// Diagonal row
rightDiagonal(X,Y) :- available(X,Y) & coincide(X+1,Y+1,X+2,Y+2).
rightDiagonal(X,Y) :- available(X,Y) & coincide(X-1,Y-1,X+1,Y+1).
rightDiagonal(X,Y) :- available(X,Y) & coincide(X-1,Y-1,X-2,Y-2).

leftDiagonal(X,Y) :- available(X,Y) & coincide(X+1,Y-1,X+2,Y-2).
leftDiagonal(X,Y) :- available(X,Y) & coincide(X-1,Y+1,X+1,Y+1).
leftDiagonal(X,Y) :- available(X,Y) & coincide(X-1,Y+1,X-2,Y+2).

// Winning position
winpos(X,Y) :- horizontal(X,Y) & (my_piece(X,Y+1) | my_piece(X,Y-1)).
winpos(X,Y) :- vertical(X,Y) & (my_piece(X+1,Y) | my_piece(X-1,Y)).
winpos(X,Y) :- rightDiagonal(X,Y) & (my_piece(X+1,Y+1) | my_piece(X-1,Y-1)).
winpos(X,Y) :- leftDiagonal(X,Y) & (my_piece(X+1,Y-1) | my_piece(X-1,Y+1)).
// Losing position
savepos(X,Y) :- horizontal(X,Y) & (opponent_piece(X,Y+1) | opponent_piece(X,Y-1)).
savepos(X,Y) :- vertical(X,Y) & (opponent_piece(X+1,Y) | opponent_piece(X-1,Y)).
savepos(X,Y) :- rightDiagonal(X,Y) & (opponent_piece(X+1,Y+1) | opponent_piece(X-1,Y-1)).
savepos(X,Y) :-leftDiagonal(X,Y) & (opponent_piece(X+1,Y-1) | opponent_piece(X-1,Y+1)).


// Starting the agent
started.

/* When the agent is started, perform the 'sayHello' action. */
+started <- sayHello.

/* Whenever it is my turn, look for winning positions. If there are none, look for positions
 to avoid a loss, and if there are none either, play if possible (in this order of preference): 
 middle, corner, edge.*/
+round(Z) : next <- !playWin. 

// Look for winning positions
+!playWin <- .findall(winpos(X,Y), winpos(X,Y), PossibleWins);
					N_winners = .length(PossibleWins);
					if (N_winners > 0) {
						.print("I see a winning movement!");
						.nth(0, PossibleWins, winpos(A,B));
						play(A,B)}
					else {!playSafe}.

// Look for positions to avoid a loss
+!playSafe <- .findall(savepos(X,Y), savepos(X,Y), PossibleSaves);
			  N_savers = .length(PossibleSaves);
			  if (N_savers > 0) {
				  .print("I see a possible loss!");
				  .nth(0, PossibleSaves, savepos(A,B));
				  play(A,B)}
			else {!playMiddle;}.

// Play in the middle if possible					
+!playMiddle <- if (available(1,1)){
					play(1,1);
				.print("Middle was available!")}
				else {!playCorner}.

// Play in a corner if possible
+!playCorner <- if (available(0,0)) {play(0,0)} else{
	if (available(2,0)) {play(2,0)} else{
	if (available(0,2)) {play(0,2)} else{
	if (available(2,2)) {play(2,2)} else{
	!playEdge
	}}}}.

// Play in an edge if possible. This should always be possible
+!playEdge <- if (available(1,0)) {play(1,0)} else{
	if (available(0,1)) {play(0,1)} else{
	if (available(2,1)) {play(2,1)} else{
	if (available(1,2)) {play(1,2)} else{
	.print("Something unexpected occurred!")	
	}}}}.

						 
/* If I am the winner, then print "Supreme victory!"  */
+winner(S) : symbol(S) <- .print("Supreme victory!").

+end <- confirmEnd.