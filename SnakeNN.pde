import java.util.*;

int windowSide = 300;
int sideOfPlay = 15;
int numberOfNodeInHL = 50;
int pointsForFood;
int maxNumberOfStepBeforeKill;

int numberOfInstances = 20;

ArrayList<Snake> bufferSnakes;
ArrayList<Snake> bestSnakes;

float sideOfASquare;

float timeClock = 50;
//int clock = timeClock;
int prevMillis = 0;

ArrayList<PVector> foods;
int numberOfFoods = 10;
EvolutionManager evolManager;

boolean pause = false;
boolean toAcquarium = false;

Snake loadedToAcquarium = null;

myThread newGeneration;

void setup() {
  surface.setSize(windowSide, windowSide);

  sideOfASquare = windowSide / sideOfPlay;
  pointsForFood = Math.round(sideOfPlay*2);
  maxNumberOfStepBeforeKill = 10 * sideOfPlay;

  foods = new ArrayList<PVector>();
  PVector tmpFood;
  for (int i = 1; i <= numberOfFoods; i++) {
    tmpFood = new PVector((float)Math.floor(random(0, sideOfPlay - 1)), (float)Math.floor(random(0, sideOfPlay - 1)));
    if (foods.size() == 0) {
      foods.add(tmpFood.copy());
    } else {
      if (PVector.dist(tmpFood, foods.get(foods.size() - 1)) == 0) {
        i--;
      } else {
        foods.add(tmpFood.copy());
      }
    }
  }

  bestSnakes = new ArrayList<Snake>();
  bufferSnakes = new ArrayList<Snake>();

  evolManager = new EvolutionManager();

  for (int i = 0; i < Math.pow(numberOfInstances, 2); i++) {
    bufferSnakes.add(new Snake());
  } 

  newGeneration = new myThread();
  newGeneration.start();

  textAlign(CENTER);
}

void draw() {
  background(255);

  if (toAcquarium == false) {
    if (bestSnakes.size() > evolManager.actualGeneration) {
      Snake best = bestSnakes.get(evolManager.actualGeneration);
      best.Draw();

      println("Generated: " + (bestSnakes.size() - 1) + " Actual: " + evolManager.actualGeneration + " Score: " + Math.round(best.score/pointsForFood));

      if (millis() - prevMillis > timeClock && pause == false) {
        prevMillis = millis();

        best.Think();
        best.Move();
      }

      if (best.isDead == true) {
        best.Initialize();
        evolManager.actualGeneration = bestSnakes.size() - 1;
        //if (bestSnakes.size() > evolManager.actualGeneration) {
        //  best.Initialize();
        //}
      }
    }
  }



  if (toAcquarium == true) {
    String[] lines = loadStrings("snakeSelected.txt");

    if (lines != null) {
      ArrayList<String> toLoad = new ArrayList<String>(Arrays.asList(lines));
    }
  }
}


class myThread extends Thread {
  boolean active;

  void start() {
    active = true;
    super.start();
  }
  void run () {
    while (true) {
      if (active) {
        execute();
      } else {
        break;
      }
    }
  }
  void execute() {
    while (evolManager.generation < evolManager.maxGenerations) {
      while (getNumberOfCreaturesAlive(bufferSnakes) != 0) {
        for (int i = 0; i < bufferSnakes.size(); i++) {
          bufferSnakes.get(i).Think();
          bufferSnakes.get(i).Move();
        }
      }
      evolManager.nextGeneration();
    }
  }
  boolean isActive() {
    return active;
  }
  void quit() {
    active = false;
    interrupt();
  }
}

int getNumberOfCreaturesAlive(ArrayList<Snake> _snakes) {
  int nCreatAlive = 0;
  for (Snake s : _snakes) {
    if (s.isDead == false) {
      nCreatAlive++;
    }
  }

  return nCreatAlive;
}

//void mouseClicked() {
//  if (mouseButton == LEFT) {
//    int x = (int)Math.floor(mouseX / sideOfASingleInstance);
//    int y = (int)Math.floor(mouseY / sideOfASingleInstance);

//    int index = x + numberOfInstances * y;

//    if (actualSnakes.get(index) != null) {
//      Brain selected = actualSnakes.get(index).brain;

//      ArrayList<String> toSave = new ArrayList<String>();

//      for (Node n : selected.inputs) {
//        toSave.addAll(n.getStringsValue());
//      }

//      for (hiddenLayer hl : selected.hiddenLayers) {
//        for (Node n : hl.nodes) {
//          toSave.addAll(n.getStringsValue());
//        }
//      }

//      saveStrings("snakeSelected.txt", toSave.toArray(new String[toSave.size()]));
//    }
//  }
//}

void keyPressed() {
  if (key == '+') {
    timeClock /= 1.2f;
  } else if (key == '-') {
    timeClock *= 1.2f;
  } else if (key == 'S') {
    evolManager.softMutationRate +=1f;
  } else if (key == 'A') {
    evolManager.softMutationRate -=1f;
  } else if (key == 'X') {
    evolManager.hardMutationRate +=0.1f;
  } else if (key == 'Z') {
    evolManager.hardMutationRate -=0.1f;
  } else if (key == 's') {
    evolManager.softMutationRate +=0.1f;
  } else if (key == 'a') {
    evolManager.softMutationRate -=0.1f;
  } else if (key == 'x') {
    evolManager.hardMutationRate +=0.01f;
  } else if (key == 'z') {
    evolManager.hardMutationRate -=0.01f;
  } else if (key == ' ') {
    pause = (pause == true) ? false : true;
  } else if (key == 'j') {
    toAcquarium = (toAcquarium == false) ? true : false;
  } else if (key == 'o') {
    if (bestSnakes.size() - 1 - evolManager.actualGeneration >= 1) {
      evolManager.actualGeneration += 1;
    } else {
      evolManager.actualGeneration = bestSnakes.size() - 1;
    }
  } else if (key == 'i') {
    if (evolManager.actualGeneration >= 1) {
      evolManager.actualGeneration -= 1;
    } else {
      evolManager.actualGeneration = 0;
    }
  } else if (key == 'O') {
    if (bestSnakes.size() - 1 - evolManager.actualGeneration >= 10) {
      evolManager.actualGeneration += 10;
    } else {
      evolManager.actualGeneration = bestSnakes.size() - 1;
    }
  } else if (key == 'I') {
    if (evolManager.actualGeneration >= 10) {
      evolManager.actualGeneration -= 10;
    } else {
      evolManager.actualGeneration = 0;
    }
  }
}
