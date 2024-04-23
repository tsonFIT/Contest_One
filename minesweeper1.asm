include irvine32.inc

.data
gridSize EQU 10 ; Change this value to set the size of the grid
gridSizeSquare EQU gridSize*gridSize
mineCount EQU gridSizeSquare/6 ; Approximately 1/6th of the cells are mines
grid BYTE gridSizeSquare DUP(0)
mines BYTE gridSizeSquare DUP(0)
msgIntroPrompt BYTE "Welcome to Minesweeper! Press any key to start.",0
msgRevealPrompt BYTE "Reveal a cell (row column): ",0
msgMineHitPrompt BYTE "You hit a mine! Game over!",0
msgWinPrompt BYTE "Congratulations! You have won!",0

.code
start:
    call SetupGrid
    call PopulateMines
    call DisplayGrid
    mov edx, OFFSET msgIntroPrompt
    call WriteString
    call ReadChar

gameLoop:
    call Clrscr
    call DisplayGrid
    mov edx, OFFSET msgRevealPrompt
    call WriteString
    call ReadInt ; Read row
    dec eax       ; Decrement row by 1 to match array indexing
    mov esi, eax
    call ReadInt ; Read column
    dec eax       ; Decrement column by 1 to match array indexing
    mov edi, eax
    call CheckCell
    cmp al, 1 ; Hit a mine
    je mineHit
    call CheckWin
    cmp al, 1 ; Won the game
    je gameWon
    jmp gameLoop

mineHit:
    mov edx, OFFSET msgMineHitPrompt
    call WriteString
    jmp endGame

gameWon:
    mov edx, OFFSET msgWinPrompt
    call WriteString
    jmp endGame

endGame:
    call ReadChar ; Wait for user to exit
    exit

SetupGrid PROC
    mov esi, 0 ; Initialize index
    mov ecx, gridSizeSquare ; Loop counter
    mov al, 45 ; Empty cell character

initLoop:
    mov grid[esi], al ; Initialize cell
    inc esi ; Move to next cell
    loop initLoop
    ret
SetupGrid ENDP

PopulateMines PROC
    mov esi, 0 ; Initialize index
    mov ecx, mineCount ; Loop counter

popLoop:
    call Randomize
    mov eax, gridSizeSquare ; Maximum random value
    call RandomRange
    mov ebx, eax ; Random cell index
    cmp ebx, gridSizeSquare
    jae popLoop
    mov al, mines[ebx] ; Check if mine already exists at this cell
    cmp al, 1
    je popLoop ; If mine exists, generate a new random index
    mov mines[ebx], 1 ; Place mine at random cell
    inc esi ; Move to next mine
    loop popLoop
    ret
PopulateMines ENDP

DisplayGrid PROC
    mov esi, 0 ; Initialize row index
    mov ecx, gridSize ; Loop counter for rows

displayRowLoop:
    push ecx
    mov edi, 0 ; Initialize column index
    mov ecx, gridSize ; Loop counter for columns

displayColLoop:
    mov eax, esi ; Calculate grid index
    mov ebx, gridSize
    mul ebx
    add eax, edi
    mov al, grid[eax] ; Get cell value
    mov dl, al ; Set display character
    cmp dl, 1 ; Check if cell is a mine
    je displayMine
    cmp dl, 2 ; Check if cell is revealed
    je displayCell
    mov dl, 45 ; ASCII value for '-'

displayCell:
    call WriteChar
    jmp nextCol

displayMine:
    mov dl, '*' ; Mine character
    call WriteChar
    jmp nextCol

nextCol:
    inc edi ; Move to next column
    loop displayColLoop
    call Crlf ; Newline for next row
    inc esi ; Move to next row
    pop ecx
    loop displayRowLoop
    ret
DisplayGrid ENDP

CheckCell PROC
    mov eax, esi ; Calculate grid index
    mov ebx, gridSize
    mul ebx
    add eax, edi
    mov al, grid[eax] ; Get cell value
    cmp al, 1 ; Check if cell is a mine
    je hitMine
    mov grid[eax], 2 ; Mark cell as revealed
    xor al, al ; Set return value to indicate not a mine
    ret

hitMine:
    mov al, 1 ; Set return value to indicate mine hit
    ret
CheckCell ENDP

CheckWin PROC
    mov esi, 0 ; Initialize index
    mov ecx, gridSizeSquare ; Loop counter

checkLoop:
    mov al, grid[esi] ; Get cell value
    cmp al, 45 ; Compare with ASCII value for '-'
    je notWon
    inc esi ; Move to next cell
    loop checkLoop
    mov al, 1 ; Set return value to indicate win
    ret

notWon:
    mov al, 0 ; Set return value to indicate not won
    ret
CheckWin ENDP

RandomRange PROC
    ; Generate a random number in eax between 0 and (edx-1)
    mov eax, edx
    imul eax, eax
    call Random32
    xor edx, edx ; Clear upper 32 bits of edx
    div edx ; eax = eax % edx
    ret
RandomRange ENDP

End start