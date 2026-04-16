void spawnAllAgents() {
    for (int agentID = 0; agentID < agentCount; agentID++) {
        // For Preset 4 spawning agents in a small cluster at the top-left corner
        if (currentSimulationPreset == 4) { 
            agentPositionX[agentID] = random(15, 35); 
            agentPositionY[agentID] = random(15, 35);
        } else {
            float spawnDistance = random(min(SCREEN_WIDTH, SCREEN_HEIGHT) * agentSpawnRadius);
            float spawnAngle = random(TWO_PI);
            agentPositionX[agentID] = SCREEN_WIDTH / 2 + cos(spawnAngle) * spawnDistance;
            agentPositionY[agentID] = SCREEN_HEIGHT / 2 + sin(spawnAngle) * spawnDistance;
            
            // Directions for each spawn mode
            switch (agentSpawnMode) {
                case 1: agentDirection[agentID] = spawnAngle + PI; break;      // Inward
                case 2: agentDirection[agentID] = spawnAngle; break;           // Outward
                case 3: agentDirection[agentID] = spawnAngle + HALF_PI; break; // Vortex
                default: agentDirection[agentID] = random(TWO_PI);             // Random
            }
        }
        
        agentSpecies[agentID] = isTwoSpeciesMode ? (int) random(2) : 0;
    }
    
    clearAllBuffers();
}

void clearAllBuffers() {
    Arrays.fill(trailMapSpeciesA, 0); 
    Arrays.fill(trailNextMapA, 0);
    Arrays.fill(trailMapSpeciesB, 0); 
    Arrays.fill(trailNextMapB, 0);
}

void generateMaze() {
    Arrays.fill(wallMap, false);
    int cellSize = 40;
    int gridColumns = SCREEN_WIDTH / cellSize;
    int gridRows = SCREEN_HEIGHT / cellSize;
    boolean[][] visitedCells = new boolean[gridColumns][gridRows];
    boolean[][][] cellWalls = new boolean[gridColumns][gridRows][2]; 

    for (int col = 0; col < gridColumns; col++) {
        for (int row = 0; row < gridRows; row++) { 
            cellWalls[col][row][0] = true;
            cellWalls[col][row][1] = true;  
        }
    }
    
    // Depth-first search maze generation
    ArrayList<int[]> depthStack = new ArrayList<>();
    visitedCells[0][0] = true; 
    depthStack.add(new int[]{0, 0});
    
    while (!depthStack.isEmpty()) {
        int[] currentCell = depthStack.get(depthStack.size() - 1);
        int currentColumn = currentCell[0], currentRow = currentCell[1];
        ArrayList<int[]> unvisitedNeighbors = new ArrayList<>();
        
        if (currentRow > 0 && !visitedCells[currentColumn][currentRow - 1]) {
            unvisitedNeighbors.add(new int[]{currentColumn, currentRow - 1, 0});
        }
        if (currentColumn < gridColumns - 1 && !visitedCells[currentColumn + 1][currentRow]) {
            unvisitedNeighbors.add(new int[]{currentColumn + 1, currentRow, 1}); 
        }
        if (currentRow < gridRows - 1 && !visitedCells[currentColumn][currentRow + 1]) {
            unvisitedNeighbors.add(new int[]{currentColumn, currentRow + 1, 2});
        }
        if (currentColumn > 0 && !visitedCells[currentColumn - 1][currentRow]) {
            unvisitedNeighbors.add(new int[]{currentColumn - 1, currentRow, 3});
        }
        
        if (unvisitedNeighbors.size() > 0) {
            int[] nextCell = unvisitedNeighbors.get((int) random(unvisitedNeighbors.size()));
            int nextColumn = nextCell[0], nextRow = nextCell[1], direction = nextCell[2];
            
            if (direction == 0) cellWalls[currentColumn][currentRow - 1][1] = false;
            else if (direction == 1) cellWalls[currentColumn][currentRow][0] = false;
            else if (direction == 2) cellWalls[currentColumn][currentRow][1] = false;
            else if (direction == 3) cellWalls[currentColumn - 1][currentRow][0] = false;
            
            visitedCells[nextColumn][nextRow] = true; 
            depthStack.add(new int[]{nextColumn, nextRow});
        } else {
            depthStack.remove(depthStack.size() - 1);
        }
    }
    
    for (int col = 0; col < gridColumns; col++) {
        for (int row = 0; row < gridRows; row++) {
            int cellX = col * cellSize, cellY = row * cellSize;
            if (cellWalls[col][row][0]) drawWallSegment(cellX + cellSize, cellY, cellX + cellSize, cellY + cellSize, 3);
            if (cellWalls[col][row][1]) drawWallSegment(cellX, cellY + cellSize, cellX + cellSize, cellY + cellSize, 3);
        }
    }
    
    // Scattering food randomly across the maze
    foodCount = 30;
    for (int foodIndex = 0; foodIndex < foodCount; foodIndex++) {
        foodPositionX[foodIndex] = (int)random(gridColumns) * cellSize + cellSize / 2;
        foodPositionY[foodIndex] = (int)random(gridRows) * cellSize + cellSize / 2;
    }
}

void drawWallSegment(int startX, int startY, int endX, int endY, float thickness) {
    float segmentLength = dist(startX, startY, endX, endY);
    for (int step = 0; step <= segmentLength; step++) {
        int currentX = (int) lerp(startX, endX, step / segmentLength);
        int currentY = (int) lerp(startY, endY, step / segmentLength);
        for (int offsetY = -(int)thickness; offsetY <= (int)thickness; offsetY++) {
            for (int offsetX = -(int)thickness; offsetX <= (int)thickness; offsetX++) {
                if (offsetX * offsetX + offsetY * offsetY <= thickness * thickness) {
                    int paintX = currentX + offsetX, paintY = currentY + offsetY;
                    if (paintX >= 0 && paintX < SCREEN_WIDTH && paintY >= 0 && paintY < SCREEN_HEIGHT) {
                        wallMap[paintY * SCREEN_WIDTH + paintX] = true;
                    }
                }
            }
        }
    }
}