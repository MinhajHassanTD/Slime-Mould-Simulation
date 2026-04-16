void buildUserInterface() {
    parameterSliders = new Slider[11];
    int panelX = 30;
    int sliderStartY = 130;
    int verticalGap = 42;
    int sliderWidth = 220;

    parameterSliders[0] = new Slider("Sensor Angle", 0, 120, degrees(sensorAngleSpreader), panelX, sliderStartY, sliderWidth);
    parameterSliders[1] = new Slider("Sensor Distance", 1, 40, sensorDistanceAhead, panelX, sliderStartY += verticalGap, sliderWidth);
    parameterSliders[2] = new Slider("Turn Speed", 0, 90, degrees(rotationSpeed), panelX, sliderStartY += verticalGap, sliderWidth);
    parameterSliders[3] = new Slider("Move Speed", 0.1f, 5, movementSpeed, panelX, sliderStartY += verticalGap, sliderWidth);
    parameterSliders[4] = new Slider("Decay Rate", 0.8f, 0.999f, pheromoneDecayRate, panelX, sliderStartY += verticalGap, sliderWidth);
    parameterSliders[5] = new Slider("Diffusion", 0.0f, 1.0f, diffusionFactor, panelX, sliderStartY += verticalGap, sliderWidth);
    parameterSliders[6] = new Slider("Deposit Amount", 0.5f, 10, depositAmountPerStep, panelX, sliderStartY += verticalGap, sliderWidth);

    parameterSliders[7] = new Slider("Spawn Radius", 0.05f, 0.5f, agentSpawnRadius, panelX, 520, sliderWidth);

    parameterSliders[8] = new Slider("Brush Radius", 2, 100, brushRadiusSize, panelX, 710, sliderWidth);
    parameterSliders[9] = new Slider("Zoom Level", 1.5f, 10.0f, zoomLevel, panelX, 755, sliderWidth);
    parameterSliders[10] = new Slider("Brush Strength", 5, 255, brushStrengthIntensity, panelX, 800, sliderWidth);

    spawnModeButton = new Button("Spawn Mode", panelX, 460, sliderWidth, 35, color(35, 50, 65));
    respawnButton = new Button("RESPAWN [ R ]", panelX, 555, sliderWidth, 38, color(40, 80, 100));
    brushModeButton = new Button("Brush Type", panelX, 650, sliderWidth, 35, color(35, 50, 65));
}

void updateSimulationParametersFromUI() {
    sensorAngleSpreader = radians(parameterSliders[0].currentValue); 
    sensorDistanceAhead = parameterSliders[1].currentValue; 
    rotationSpeed = radians(parameterSliders[2].currentValue); 
    movementSpeed = parameterSliders[3].currentValue; 
    pheromoneDecayRate = parameterSliders[4].currentValue; 
    diffusionFactor = parameterSliders[5].currentValue; 
    depositAmountPerStep = parameterSliders[6].currentValue;
    agentSpawnRadius = parameterSliders[7].currentValue; 
    brushRadiusSize = parameterSliders[8].currentValue; 
    zoomLevel = parameterSliders[9].currentValue;
    brushStrengthIntensity = parameterSliders[10].currentValue; 
}

void loadPreset(int presetID) {
    currentSimulationPreset = presetID;
    foodCount = 0; 
    Arrays.fill(wallMap, false); 

    switch(presetID) {
        case 1:
            configureSliders(22.5f, 15, 15, 1.5f, 0.96f, 0.5f, 4);
            agentSpawnMode = 1; 
            parameterSliders[7].currentValue = 0.3f; 
            isTwoSpeciesMode = false;
            buildColorThemes(currentColorTheme = 0);
            break;
            
        case 2: 
            configureSliders(45, 9, 30, 1.0f, 0.90f, 0.1f, 5);
            agentSpawnMode = 0; 
            parameterSliders[7].currentValue = 0.3f; 
            isTwoSpeciesMode = false;
            buildColorThemes(currentColorTheme = 1);
            break;
            
        case 3:
            configureSliders(10, 25, 20, 2.5f, 0.98f, 0.8f, 2);
            agentSpawnMode = 3; 
            parameterSliders[7].currentValue = 0.3f; 
            isTwoSpeciesMode = true;
            buildColorThemes(currentColorTheme = 2);
            break;
            
        case 4:
            configureSliders(35, 20, 25, 1.5f, 0.99f, 0.1f, 5);
            agentSpawnMode = 0; 
            isTwoSpeciesMode = true; 
            buildColorThemes(currentColorTheme = 3);
            generateMaze();
            break;
    }
    
    updateSimulationParametersFromUI();
    spawnAllAgents();
}

void configureSliders(float sensorAngle, float sensorDist, float turnSpd, float moveSpd, float decayRt, float diffus, float deposit) {
    parameterSliders[0].currentValue = sensorAngle;  
    parameterSliders[1].currentValue = sensorDist;   
    parameterSliders[2].currentValue = turnSpd;
    parameterSliders[3].currentValue = moveSpd;     
    parameterSliders[4].currentValue = decayRt;     
    parameterSliders[5].currentValue = diffus;
    parameterSliders[6].currentValue = deposit;
}

void drawControlPanel() {
    fill(10, 20, 30, 230); 
    noStroke(); 
    rect(10, 10, 350, SCREEN_HEIGHT - 20, 10); 
    
    fill(100, 200, 255); 
    textSize(26);
    textAlign(LEFT, TOP); 
    text("SLIME MOLD SIMULATION", 30, 35);
    
    fill(150); 
    textSize(16);
    text("AGENTS: " + agentCount + " | FPS: " + (int) frameRate, 30, 70);
    text("THEME: " + themeDisplayNames[currentColorTheme] + " | SPECIES: " + (isTwoSpeciesMode ? "2" : "1"), 30, 90);
    
    for (int i = 0; i < 7; i++) parameterSliders[i].draw();
    
    drawPanelSectionHeader("SPAWNING", 440, 65);
    spawnModeButton.label = spawnModeNames[agentSpawnMode]; 
    spawnModeButton.draw();
    parameterSliders[7].draw(); 
    respawnButton.draw();
    
    drawPanelSectionHeader("INTERACTION", 630, 58);
    brushModeButton.label = "Brush: " + brushModeNames[brushMode]; 
    brushModeButton.draw(brushModeColors[brushMode]);
    parameterSliders[8].draw(); 
    parameterSliders[9].draw(); 
    
    fill(80, 120, 150);
    textSize(14);
    textAlign(CENTER, BOTTOM);
    text("[1-4] Presets | [A] Show Agents | [H] Hide UI | [Z] Zoom", 185, SCREEN_HEIGHT - 30);
}

void drawPanelSectionHeader(String sectionLabel, int yPosition, int xOffset) {
    fill(60, 100, 130); 
    textSize(17);
    textAlign(LEFT, TOP);
    text("─── " + sectionLabel + " ───", xOffset, yPosition);
}