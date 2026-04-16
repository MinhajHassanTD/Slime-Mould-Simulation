void updateAllAgents() {
    for (int agentID = 0; agentID < agentCount; agentID++) {
        float positionX = agentPositionX[agentID];
        float positionY = agentPositionY[agentID];
        float currentDirection = agentDirection[agentID];
        
        // Selecting the trail map based on agent species
        float[] trailToFollow = (agentSpecies[agentID] == 0) ? trailMapSpeciesA : trailMapSpeciesB;

        // Sensing the pheromone concentration in three directions: ahead, left, and right
        float sensorAhead = senseTrailAt(positionX, positionY, currentDirection, sensorDistanceAhead, trailToFollow);
        float sensorLeft = senseTrailAt(positionX, positionY, currentDirection - sensorAngleSpreader, sensorDistanceAhead, trailToFollow);
        float sensorRight = senseTrailAt(positionX, positionY, currentDirection + sensorAngleSpreader, sensorDistanceAhead, trailToFollow);

        float randomFactor = random(1.0f);
        
        // Steering decision based on sensed pheromone concentrations with added randomness to prevent deadlocks and promote exploration
        if (sensorAhead > sensorLeft && sensorAhead > sensorRight) {
            // move straight
        } else if (sensorAhead < sensorLeft && sensorAhead < sensorRight) {
            // randomly choosing left or right if both are better than ahead
            currentDirection += (randomFactor - 0.5f) * 2.0f * rotationSpeed;
        } else if (sensorLeft > sensorRight) {
            // move left
            currentDirection -= rotationSpeed * randomFactor; 
        } else if (sensorRight > sensorLeft) {
            // move right 
            currentDirection += rotationSpeed * randomFactor; 
        } else {
            // moving randomly
            currentDirection += (randomFactor - 0.5f) * rotationSpeed;
        }

        // Calculating the next position based on direction and movement speed
        float nextPositionX = positionX + getFastCosine(currentDirection) * movementSpeed;
        float nextPositionY = positionY + getFastSine(currentDirection) * movementSpeed;

        // Handling the boundary wrapping with reflection
        if (nextPositionX < 0 || nextPositionX >= SCREEN_WIDTH) { 
            currentDirection = PI - currentDirection;
            nextPositionX = constrain(nextPositionX, 0, SCREEN_WIDTH - 1); 
        }
        if (nextPositionY < 0 || nextPositionY >= SCREEN_HEIGHT) { 
            currentDirection = -currentDirection;
            nextPositionY = constrain(nextPositionY, 0, SCREEN_HEIGHT - 1); 
        }

        int pixelIndex = (int) nextPositionY * SCREEN_WIDTH + (int) nextPositionX;
        
        // Checking for wall collision
        if (wallMap[pixelIndex]) {
            // Bounce off wall by changing direction randomly
            currentDirection = random(TWO_PI);
            nextPositionX = positionX;
            nextPositionY = positionY;
        } else {
            // Depositing the pheromone at current location
            trailToFollow[pixelIndex] = min(255, trailToFollow[pixelIndex] + depositAmountPerStep);
        }

        agentPositionX[agentID] = nextPositionX; 
        agentPositionY[agentID] = nextPositionY; 
        agentDirection[agentID] = currentDirection;
    }
}

float senseTrailAt(float baseX, float baseY, float angleToSense, float distanceToSense, float[] currentTrailMap) {
    int senseX = round(baseX + getFastCosine(angleToSense) * distanceToSense);
    int senseY = round(baseY + getFastSine(angleToSense) * distanceToSense);
    
    // Out of bounds means no signal
    if (senseX < 0 || senseX >= SCREEN_WIDTH || senseY < 0 || senseY >= SCREEN_HEIGHT) {
        return -1;
    }
    
    int pixelIndex = senseY * SCREEN_WIDTH + senseX;
    
    // Wall penalty to force avoidance
    if (wallMap[pixelIndex]) return -5000.0f;
    
    return currentTrailMap[pixelIndex];
}

float getFastCosine(float angle) { 
    float normalizedAngle = angle % TWO_PI; 
    if (normalizedAngle < 0) normalizedAngle += TWO_PI; 
    return cosineTable[(int)((normalizedAngle / TWO_PI) * TRIG_LOOKUP_SIZE) % TRIG_LOOKUP_SIZE]; 
}

float getFastSine(float angle) { 
    float normalizedAngle = angle % TWO_PI; 
    if (normalizedAngle < 0) normalizedAngle += TWO_PI; 
    return sineTable[(int)((normalizedAngle / TWO_PI) * TRIG_LOOKUP_SIZE) % TRIG_LOOKUP_SIZE]; 
}