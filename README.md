# Slime Mould Simulation

An interactive agent-based slime mould simulation built in Processing. The project models emergent trail-forming behavior using large populations of autonomous agents that sense, move, deposit pheromones, and self-organize into dynamic network-like patterns.

This project was built as a university assignment/project.

## Demo Video

[Watch on YouTube](https://www.youtube.com/watch?v=YP1a00J-j-M)

## Tech Stack

- Processing (Java mode)
- Java (within the Processing runtime)
- Processing P2D renderer for real-time visualization

## Notable Features

- Large-scale simulation (up to 200,000 agents)
- Real-time pheromone sensing, deposition, diffusion, and decay
- Optional two-species mode with blended rendering
- Multiple spawn behaviors: Random, Inward, Outward, Vortex
- Interactive canvas tools for painting trails, drawing walls, and placing food sources
- Four built-in presets (including maze generation)
- Live parameter controls via HUD sliders and buttons
- Zoom lens and optional agent visualization overlay
- Color theme cycling for different visual styles

## Controls

- `1-4`: Load simulation presets
- `R`: Respawn agents
- `M`: Toggle one/two species mode
- `T`: Cycle color theme
- `A`: Toggle agent visualization
- `H`: Toggle HUD visibility
- `Z`: Toggle zoom lens
- `E`: Cycle brush type
- Left click/drag on canvas: Paint with active brush
- Right click/drag on canvas: Erase trails/walls and remove nearby food

## Installation and Run

### Option 1: Processing IDE (recommended)

1. Install Processing from https://processing.org/download.
2. Open `src/src.pde` in the Processing IDE.
3. Ensure all `.pde` files remain in the same `src/` folder.
4. Click **Run**.

### Option 2: VS Code + Processing extension

1. Install Processing.
2. Open this repository in VS Code.
3. Use a Processing-compatible extension/workflow to run `src/src.pde`.

## Project Structure

- `src/src.pde`: Main setup/draw loop, input handling, and global state
- `src/Agents.pde`: Agent movement, sensing, and steering logic
- `src/Environment.pde`: Trail diffusion/decay, food scent, and brush painting
- `src/Rendering.pde`: Frame rendering, themes, food markers, and zoom lens
- `src/Spawning.pde`: Agent spawning, buffer clearing, and maze generation
- `src/UI.pde`: HUD, sliders, buttons, and presets
- `src/Classes.pde`: UI component classes (`Button`, `Slider`)