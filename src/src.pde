import java.util.ArrayList;
import java.util.Arrays;

final int SCREEN_WIDTH  = 1600;          
final int SCREEN_HEIGHT = 1000;          

float[] trailMapSpeciesA, trailNextMapA;
float[] trailMapSpeciesB, trailNextMapB;
boolean[] wallMap;     
PImage displayImage; 

int agentCount = 200000;
float[] agentPositionX = new float[agentCount];
float[] agentPositionY = new float[agentCount];
float[] agentDirection = new float[agentCount];       
int[] agentSpecies = new int[agentCount]; 

final int MAX_FOOD_SOURCES = 30;
float[] foodPositionX = new float[MAX_FOOD_SOURCES];
float[] foodPositionY = new float[MAX_FOOD_SOURCES];
int foodCount = 0;

float sensorAngleSpreader, sensorDistanceAhead;            
float rotationSpeed, movementSpeed;          
float pheromoneDecayRate, diffusionFactor, depositAmountPerStep;            

int agentSpawnMode = 0; // 0: Random, 1: Inward, 2: Outward, 3: Vortex
float agentSpawnRadius = 0.3f;  
int currentSimulationPreset = 1;
float brushRadiusSize = 30.0f;
float brushStrengthIntensity = 100.0f;
float zoomLevel = 3.0f;
int brushMode = 0; // 0: Trail, 1: Wall, 2: Food

boolean isTwoSpeciesMode = false;
boolean showAgentVisualization = false;
int currentColorTheme = 0;
int[] colorPaletteA = new int[256];
int[] colorPaletteB = new int[256];

String[] themeDisplayNames = {"1", "2", "3", "4", "5"};
String[] spawnModeNames = {"Random", "Inward", "Outward", "Vortex"};
String[] brushModeNames = {"TRAIL", "WALL", "FOOD"};
int[] brushModeColors;

// Precomputed trigonometric lookup tables for performance optimization
final int TRIG_LOOKUP_SIZE = 4096;
float[] cosineTable = new float[TRIG_LOOKUP_SIZE];
float[] sineTable = new float[TRIG_LOOKUP_SIZE];

Slider[] parameterSliders;
Button spawnModeButton, respawnButton, brushModeButton;
boolean isHUDVisible = true;
boolean isZoomModeActive = false;

void setup() {
    size(1600, 1000, P2D); 
    pixelDensity(1);          
    frameRate(60);

    brushModeColors = new int[]{ color(50, 255, 100), color(100, 150, 255), color(255, 255, 50) };

    // Precomputing the trigonometric tables for faster agent movement calculations
    for (int i = 0; i < TRIG_LOOKUP_SIZE; i++) {
        float radian = (i / (float) TRIG_LOOKUP_SIZE) * TWO_PI;
        cosineTable[i] = cos(radian);
        sineTable[i] = sin(radian);
    }

    // Initializing the simulation buffers
    trailMapSpeciesA = new float[SCREEN_WIDTH * SCREEN_HEIGHT];
    trailNextMapA = new float[SCREEN_WIDTH * SCREEN_HEIGHT];
    trailMapSpeciesB = new float[SCREEN_WIDTH * SCREEN_HEIGHT];
    trailNextMapB = new float[SCREEN_WIDTH * SCREEN_HEIGHT];
    wallMap = new boolean[SCREEN_WIDTH * SCREEN_HEIGHT]; 
    displayImage = createImage(SCREEN_WIDTH, SCREEN_HEIGHT, RGB);

    buildUserInterface();
    loadPreset(1);

    surface.setLocation(200, 100);
}

void draw() {
    updateSimulationParametersFromUI();

    updateFoodAttractionScent(); 
    updateAllAgents();
    updateTrailEnvironment();

    renderVisualFrame();
    image(displayImage, 0, 0);

    if (showAgentVisualization) drawVisibleAgents(0.01f);
    drawFoodSources();

    handleUserCanvasInput();
    
    if (isZoomModeActive) drawZoomLens();
    if (isHUDVisible) drawControlPanel();
}

void renderVisualFrame() {
    displayImage.loadPixels();
    
    for (int pixelIndex = 0; pixelIndex < SCREEN_WIDTH * SCREEN_HEIGHT; pixelIndex++) {
        if (wallMap[pixelIndex]) {
            displayImage.pixels[pixelIndex] = color(20, 30, 40);
        } else {
            int trailValueA = constrain((int) trailMapSpeciesA[pixelIndex], 0, 255);
            int trailValueB = constrain((int) trailMapSpeciesB[pixelIndex], 0, 255);
            
            if (!isTwoSpeciesMode || trailValueB == 0) {
                displayImage.pixels[pixelIndex] = colorPaletteA[trailValueA];
            } else if (trailValueA == 0) {
                displayImage.pixels[pixelIndex] = colorPaletteB[trailValueB];
            } else {
                // Blending the colors when 2 species overlap
                int colorA = colorPaletteA[trailValueA];
                int colorB = colorPaletteB[trailValueB];
                int blendedRed = (int) min(255, red(colorA) + red(colorB));
                int blendedGreen = (int) min(255, green(colorA) + green(colorB));
                int blendedBlue = (int) min(255, blue(colorA) + blue(colorB));
                displayImage.pixels[pixelIndex] = color(blendedRed, blendedGreen, blendedBlue);
            }
        }
    }
    
    displayImage.updatePixels();
}

void handleUserCanvasInput() {
    boolean userClickingOnCanvas = (!isHUDVisible || mouseX > 280);
    
    if (mousePressed && !isDraggingAnySlider() && userClickingOnCanvas) {
        boolean isEraseMode = (mouseButton == RIGHT);
        if (isEraseMode || brushMode != 2) {
            paintOnCanvas(mouseX, mouseY, brushRadiusSize, brushStrengthIntensity, isEraseMode);
        }
    }
}

void mousePressed() {
    if (isHUDVisible) {
        for (Slider slider : parameterSliders) {
            if (slider.isHit(mouseX, mouseY)) slider.dragging = true;
        }
        if (spawnModeButton.isHit(mouseX, mouseY)) agentSpawnMode = (agentSpawnMode + 1) % 4;
        if (respawnButton.isHit(mouseX, mouseY)) spawnAllAgents();
        if (brushModeButton.isHit(mouseX, mouseY)) brushMode = (brushMode + 1) % 3;
    }
    
    boolean userClickingOnCanvas = (!isHUDVisible || mouseX > 280);
    if (userClickingOnCanvas && mouseButton == LEFT && brushMode == 2 && !isDraggingAnySlider()) {
        if (foodCount < MAX_FOOD_SOURCES) {
            foodPositionX[foodCount] = mouseX; 
            foodPositionY[foodCount] = mouseY; 
            foodCount++;
        }
    }
}

void mouseDragged() {
    for (Slider slider : parameterSliders) {
        if (slider.dragging) slider.update(mouseX);
    }
}

void mouseReleased() {
    for (Slider slider : parameterSliders) slider.dragging = false;
}

void keyPressed() {
    if (key == 'a' || key == 'A') showAgentVisualization = !showAgentVisualization;
    if (key == 'z' || key == 'Z') isZoomModeActive = !isZoomModeActive;
    if (key == 'h' || key == 'H') isHUDVisible = !isHUDVisible;
    if (key == 'e' || key == 'E') brushMode = (brushMode + 1) % 3; 
    if (key == 'm' || key == 'M') { isTwoSpeciesMode = !isTwoSpeciesMode; spawnAllAgents(); }
    if (key == 't' || key == 'T') { currentColorTheme = (currentColorTheme + 1) % 5; buildColorThemes(currentColorTheme); }
    if (key >= '1' && key <= '4') loadPreset(key - '0');
    if (key == 'r' || key == 'R') spawnAllAgents();
}