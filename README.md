# a-game-in-which-one-player-escapes-the-aliens-and-the-other-helps-him-by-controlling-the-spaceship
#### **Core Mechanics**
 - Top down 2D view - Gracz 1 będzie się poruszał po powieszchni 2D z widokiem z góry, z możliwością obserwowania tylko jednego pokoju na raz.
 - Spaceship Management - Możliwość sterowania urządzeniami znajdującymi się na pokładzie względem kolorystyki.
 - Cooperative gameplay - Gracz 1 będzie musiał uciec ze stacji kosmicznej, gdy gracz 2 będzie kontrolował stacją, np. drzwi, działka itd.
 - Escape the spaceship - Gracz 1 musi znaleźć wyjście, które jest ukryte na poziomie pokładu.
 - Avoid aliens - Gracz 1 będzie musiał uniknąć starcia z kosmitami, które chodzą losowo po statku, poprzez bycie ostrożnym i dobrą komunikacją z graczem 2
#### **Side Mechanics**
 - Random generated map
 - Lockers functionality
 - Noise generation (Aliens would go to the loudest noise)
 - Difficulty settings:
   - Command prompts for player 2
   - Insight to other rooms for player 1
   - Doors blocked by codes
   - Switching power for colored mechanisms
   - Core failure
   - Escape room - rooms
   - Curse of darkness
 - Defend the control room as Player 2
 - Starship monitoring system
 - Mobile port
#### **Gameplay loop** (Work in Progress)
 **Player 1:**
 - **First Phase:***
   - Find the escape pod to check it's color.
   - Find the matching color terminal to open the escape pod.
 - **Second Phase:**
   - Go to the escape pod.
   - Avoid the Alien King.

 **Player 2:**
 - **First Phase:**
   - Guide Player 1 to the terminals (Player 2 do not see escape pod on map).
   - Scan rooms to check in which rooms are aliens.
   - Use buttons to open/close doors.
 - **Second Phase:**
   - Guide Player 1 to the escape pod which coordinates are know now.
   - Room scanning is not working correctly. Some rooms are not scanned.

**Aliens:**
 - **First Phase:**
   - They are wandering across the spaceship in search of Player 1.
   - When they hit Player 1 the game ends.
 - **Second Phase:**
   - The Alien King spawns in the hatchery room.
   - The Alien King knows the Player 1 location and goes to him in the shortest path.
