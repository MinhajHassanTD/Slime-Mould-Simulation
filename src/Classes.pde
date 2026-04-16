class Button {
    String label;
    int x, y, width, height;
    color baseColor;

    Button(String displayLabel, int xPosition, int yPosition, int buttonWidth, int buttonHeight, color buttonColor) {
        this.label = displayLabel;
        this.x = xPosition;
        this.y = yPosition;
        this.width = buttonWidth;
        this.height = buttonHeight;
        this.baseColor = buttonColor;
    }

    void draw() {
        draw(color(255));
    }

    void draw(color textColor) {
        boolean mouseHoveringOverButton = isMouseOver();
        
        color displayColor = mouseHoveringOverButton ? lerpColor(baseColor, color(255), 0.2f) : baseColor;
        
        fill(displayColor);
        stroke(100, 200, 255, 100);
        strokeWeight(1);
        rect(x, y, width, height, 4);

        fill(textColor);
        textSize(15);
        textAlign(CENTER, CENTER);
        text(label.toUpperCase(), x + width / 2, y + height / 2 - 1);
    }

    boolean isHit(int mousePositionX, int mousePositionY) {
        return (mousePositionX >= x && mousePositionX <= x + width && mousePositionY >= y && mousePositionY <= y + height);
    }

    private boolean isMouseOver() {
        return isHit(mouseX, mouseY);
    }
}

class Slider {
    String title;
    float minValue, maxValue, currentValue;
    int x, y, width;
    boolean dragging = false;

    Slider(String sliderTitle, float minimum, float maximum, float startingValue, int xPosition, int yPosition, int sliderWidth) {
        this.title = sliderTitle;
        this.minValue = minimum;
        this.maxValue = maximum;
        this.currentValue = startingValue;
        this.x = xPosition;
        this.y = yPosition;
        this.width = sliderWidth;
    }

    void draw() {
        // Label and current value display
        fill(200);
        noStroke();
        textSize(12);
        textAlign(LEFT, BOTTOM);
        text(title, x, y - 6);
        
        textAlign(RIGHT, BOTTOM);
        text(nf(currentValue, 0, 2), x + width, y - 6);

        // Drawing slider track
        stroke(60, 80, 100);
        strokeWeight(5);
        line(x, y, x + width, y);

        // Drawing slider handle
        float handlePositionX = map(currentValue, minValue, maxValue, x, x + width);
        
        noStroke();
        fill(dragging ? color(100, 255, 200) : color(255));
        ellipse(handlePositionX, y, 10, 10);
    }

    boolean isHit(int mousePositionX, int mousePositionY) {
        return (mousePositionX >= x - 5 && mousePositionX <= x + width + 5 && 
                mousePositionY >= y - 15 && mousePositionY <= y + 15);
    }

    void update(int mousePositionX) {
        currentValue = constrain(map(mousePositionX, x, x + width, minValue, maxValue), minValue, maxValue);
    }
}

boolean isDraggingAnySlider() { 
    if (parameterSliders == null) return false;
    for (Slider slider : parameterSliders) {
        if (slider.dragging) return true;
    }
    return false; 
}