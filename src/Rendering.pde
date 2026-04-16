void drawVisibleAgents(float displayPercentage) {
    int stepSize = max(1, (int)(1.0f / displayPercentage)); 
    strokeWeight(2); 
    
    for (int agentID = 0; agentID < agentCount; agentID += stepSize) {
        int pixelX = (int) agentPositionX[agentID];
        int pixelY = (int) agentPositionY[agentID];
        if (pixelX < 0 || pixelX >= SCREEN_WIDTH || pixelY < 0 || pixelY >= SCREEN_HEIGHT) continue;
        
        int pixelIndex = pixelY * SCREEN_WIDTH + pixelX;
        float trailIntensity = (agentSpecies[agentID] == 1 && isTwoSpeciesMode) ? trailMapSpeciesB[pixelIndex] : trailMapSpeciesA[pixelIndex];
        
        if (trailIntensity > 180) {
            stroke(255, 30, 30, map(trailIntensity, 180, 255, 50, 255));
            point(pixelX, pixelY);
        }
    }
}

void buildColorThemes(int themeIndex) {
    for (int intensityLevel = 0; intensityLevel < 256; intensityLevel++) {
        float normalizedIntensity = intensityLevel / 255.0f;
        float redComponent_A = 0, greenComponent_A = 0, blueComponent_A = 0;
        float redComponent_B = 0, greenComponent_B = 0, blueComponent_B = 0;

        switch (themeIndex) {
            case 0: 
                redComponent_A = intensityLevel; 
                greenComponent_A = intensityLevel; 
                blueComponent_A = intensityLevel; 
                redComponent_B = intensityLevel; 
                greenComponent_B = intensityLevel * 0.95f; 
                blueComponent_B = intensityLevel * 0.8f; 
                break;
                
            case 1: 
                greenComponent_A = intensityLevel; 
                blueComponent_A = intensityLevel / 2; 
                redComponent_B = intensityLevel; 
                blueComponent_B = intensityLevel;
                break;
                
            case 2:
                redComponent_A = intensityLevel; 
                greenComponent_A = intensityLevel > 128 ? (intensityLevel - 128) * 2 : 0;
                blueComponent_B = intensityLevel; 
                greenComponent_B = intensityLevel > 128 ? (intensityLevel - 128) * 2 : 0;
                break;
                
            case 3:
                redComponent_A = 0; 
                greenComponent_A = intensityLevel; 
                blueComponent_A = intensityLevel;
                redComponent_B = intensityLevel; 
                greenComponent_B = 0; 
                blueComponent_B = intensityLevel;
                break;
                
            case 4:
                redComponent_A = pow(normalizedIntensity, 2) * 255; 
                greenComponent_A = normalizedIntensity * 150; 
                blueComponent_A = normalizedIntensity * 200;
                redComponent_B = normalizedIntensity * 200; 
                greenComponent_B = normalizedIntensity * 150; 
                blueComponent_B = pow(normalizedIntensity, 2) * 255;
                break;
        }
        
        colorPaletteA[intensityLevel] = color(
            constrain(redComponent_A, 0, 255), 
            constrain(greenComponent_A, 0, 255), 
            constrain(blueComponent_A, 0, 255)
        );
        colorPaletteB[intensityLevel] = color(
            constrain(redComponent_B, 0, 255), 
            constrain(greenComponent_B, 0, 255), 
            constrain(blueComponent_B, 0, 255)
        );
    }
}

void drawFoodSources() {
    for (int foodIndex = 0; foodIndex < foodCount; foodIndex++) {
        float pulseFactor = (sin(frameCount * 0.15f) + 1.0f) * 0.5f; 
        float centerX = foodPositionX[foodIndex];
        float centerY = foodPositionY[foodIndex];
        float crossSize = 6 + 4 * pulseFactor;
        
        // Animating the pink cross marker
        stroke(255, 50, 255, 180 + 75 * pulseFactor); 
        strokeWeight(3);
        line(centerX - crossSize, centerY, centerX + crossSize, centerY); 
        line(centerX, centerY - crossSize, centerX, centerY + crossSize);
        
        // Drawing the Center point
        stroke(255); 
        strokeWeight(2); 
        point(centerX, centerY);
    }
    noStroke();
}

void drawZoomLens() {
    int lensWidth = 200, lensHeight = 200;
    int lensX = SCREEN_WIDTH - lensWidth - 20, lensY = SCREEN_HEIGHT - lensHeight - 20; 
    float sampleWidth = lensWidth / zoomLevel, sampleHeight = lensHeight / zoomLevel;
    float sampleX = constrain(mouseX - sampleWidth / 2, 0, SCREEN_WIDTH - sampleWidth);
    float sampleY = constrain(mouseY - sampleHeight / 2, 0, SCREEN_HEIGHT - sampleHeight);
    
    stroke(100, 200, 255); 
    strokeWeight(2); 
    noFill();
    rect(lensX - 1, lensY - 1, lensWidth + 2, lensHeight + 2);
    
    copy((int)sampleX, (int)sampleY, (int)sampleWidth, (int)sampleHeight, lensX, lensY, lensWidth, lensHeight);
}