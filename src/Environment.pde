void updateTrailEnvironment() {
    // species A trail diffusion
    processTrailDiffusion(trailMapSpeciesA, trailNextMapA);
    float[] tempBufferA = trailMapSpeciesA; 
    trailMapSpeciesA = trailNextMapA; 
    trailNextMapA = tempBufferA; 
    
    // species B trail diffusion (if enabled)
    if (isTwoSpeciesMode) {
        processTrailDiffusion(trailMapSpeciesB, trailNextMapB);
        float[] tempBufferB = trailMapSpeciesB; 
        trailMapSpeciesB = trailNextMapB; 
        trailNextMapB = tempBufferB;
    }
}

void processTrailDiffusion(float[] currentTrailState, float[] nextTrailState) {
    float preserveRatio = 1.0f - diffusionFactor;   
    
    for (int pixelY = 1; pixelY < SCREEN_HEIGHT - 1; pixelY++) {
        for (int pixelX = 1; pixelX < SCREEN_WIDTH - 1; pixelX++) {
            int pixelIndex = pixelY * SCREEN_WIDTH + pixelX;
            
            // Walls are empty of trails
            if (wallMap[pixelIndex]) { 
                nextTrailState[pixelIndex] = 0; 
                continue; 
            }

            // Calculating average of the current pixel and its 8 neighbors for diffusion
            float neighborhoodAverage = (
                currentTrailState[pixelIndex - SCREEN_WIDTH - 1] + currentTrailState[pixelIndex - SCREEN_WIDTH] + currentTrailState[pixelIndex - SCREEN_WIDTH + 1] +
                currentTrailState[pixelIndex - 1] + currentTrailState[pixelIndex] + currentTrailState[pixelIndex + 1] + currentTrailState[pixelIndex + SCREEN_WIDTH - 1] +
                currentTrailState[pixelIndex + SCREEN_WIDTH] + currentTrailState[pixelIndex + SCREEN_WIDTH + 1]
            ) / 9.0f;

            // Blending current with neighborhood average and applying decay
            nextTrailState[pixelIndex] = (currentTrailState[pixelIndex] * preserveRatio + neighborhoodAverage * diffusionFactor) * pheromoneDecayRate;
        }
    }
}

void updateFoodAttractionScent() {
    float scentSpreadRadius = SCREEN_WIDTH * 0.8f;
    
    for (int foodIndex = 0; foodIndex < foodCount; foodIndex++) {
        float foodCenterX = foodPositionX[foodIndex];
        float foodCenterY = foodPositionY[foodIndex];

        paintTrailCircle(foodCenterX, foodCenterY, 8, 255);

        for (int particleCount = 0; particleCount < 400; particleCount++) {
            float randomAngle = random(TWO_PI);
            float randomDistance = random(scentSpreadRadius);
            int spreadPointX = (int)(foodCenterX + cos(randomAngle) * randomDistance);
            int spreadPointY = (int)(foodCenterY + sin(randomAngle) * randomDistance);
            
            if (spreadPointX >= 0 && spreadPointX < SCREEN_WIDTH && spreadPointY >= 0 && spreadPointY < SCREEN_HEIGHT) {
                int pixelIndex = spreadPointY * SCREEN_WIDTH + spreadPointX;
                if (!wallMap[pixelIndex]) {
                    // scent strength decreases with distance
                    float scentStrength = map(randomDistance, 0, scentSpreadRadius, 12, 0);
                    trailMapSpeciesA[pixelIndex] = min(255, trailMapSpeciesA[pixelIndex] + scentStrength);
                    if (isTwoSpeciesMode) {
                        trailMapSpeciesB[pixelIndex] = min(255, trailMapSpeciesB[pixelIndex] + scentStrength);
                    }
                }
            }
        }
    }
}

void paintTrailCircle(float centerX, float centerY, float radius, float intensity) {
    for (int offsetY = -(int)radius; offsetY <= (int)radius; offsetY++) {
        for (int offsetX = -(int)radius; offsetX <= (int)radius; offsetX++) {
            if (offsetX * offsetX + offsetY * offsetY <= radius * radius) {
                int paintX = (int)centerX + offsetX;
                int paintY = (int)centerY + offsetY;
                if (paintX >= 0 && paintX < SCREEN_WIDTH && paintY >= 0 && paintY < SCREEN_HEIGHT) {
                    int pixelIndex = paintY * SCREEN_WIDTH + paintX;
                    if (!wallMap[pixelIndex]) {
                        trailMapSpeciesA[pixelIndex] = min(255, trailMapSpeciesA[pixelIndex] + intensity);
                    }
                }
            }
        }
    }
}

void paintOnCanvas(int mouseX, int mouseY, float radius, float strength, boolean shouldErase) {
    if (shouldErase) {
        for (int foodIndex = foodCount - 1; foodIndex >= 0; foodIndex--) {
            if (dist(mouseX, mouseY, foodPositionX[foodIndex], foodPositionY[foodIndex]) <= radius) {
                foodPositionX[foodIndex] = foodPositionX[foodCount - 1]; 
                foodPositionY[foodIndex] = foodPositionY[foodCount - 1]; 
                foodCount--;
            }
        }
    }

    for (int offsetY = -(int)radius; offsetY <= (int)radius; offsetY++) {
        for (int offsetX = -(int)radius; offsetX <= (int)radius; offsetX++) {
            if (offsetX * offsetX + offsetY * offsetY <= radius * radius) {
                int paintX = mouseX + offsetX;
                int paintY = mouseY + offsetY;
                if (paintX >= 0 && paintX < SCREEN_WIDTH && paintY >= 0 && paintY < SCREEN_HEIGHT) {
                    int pixelIndex = paintY * SCREEN_WIDTH + paintX;
                    if (shouldErase) {
                        trailMapSpeciesA[pixelIndex] = 0; 
                        trailMapSpeciesB[pixelIndex] = 0; 
                        wallMap[pixelIndex] = false;
                    } else if (brushMode == 0) { 
                        // Paint trail
                        if (!wallMap[pixelIndex]) {
                            trailMapSpeciesA[pixelIndex] = min(255, trailMapSpeciesA[pixelIndex] + strength);
                        }
                    } else if (brushMode == 1) { 
                        // Paint wall
                        wallMap[pixelIndex] = true; 
                        trailMapSpeciesA[pixelIndex] = 0; 
                        trailMapSpeciesB[pixelIndex] = 0; 
                    }
                }
            }
        }
    }
}