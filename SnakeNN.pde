import java.util.*;

int windowSide = 300;
int sideOfPlay = 3;
int numberOfNodeInHL = 5;
int pointsForFood;
int maxNumberOfStepBeforeKill;

int numberOfInstances = 10;

ArrayList<Snake> bufferSnakes;
ArrayList<Snake> bestSnakes;

float sideOfASquare;

float timeClock = 50;
//int clock = timeClock;
int prevMillis = 0;

ArrayList<PVector> foods;
int numberOfFoods = 200;
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

  createFoods();

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

void createFoods() {
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
    if (loadedToAcquarium != null) {
      loadedToAcquarium.Draw();
      if (millis() - prevMillis > timeClock && pause == false) {
        prevMillis = millis();

        loadedToAcquarium.Think();
        loadedToAcquarium.Move();
      }

      if (loadedToAcquarium.isDead == true) {
        loadedToAcquarium.Initialize();
      }
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
    while (/*evolManager.generation < evolManager.maxGenerations*/ true) {
      while (getNumberOfCreaturesAlive(bufferSnakes) != 0) {
        for (int i = 0; i < bufferSnakes.size(); i++) {
          bufferSnakes.get(i).Think();
          bufferSnakes.get(i).Move();
        }
      }
      evolManager.nextGeneration();
      //if (evolManager.generation % 200 == 0) {
      //  createFoods();
      //}
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

void Save() {
  Snake best = bestSnakes.get(evolManager.actualGeneration);

  Brain selected = best.brain;

  ArrayList<String> toSave = new ArrayList<String>();

  toSave.add(selected.inputs.size() + "");
  toSave.add(selected.hiddenLayers.size() + "");
  for (hiddenLayer hl : selected.hiddenLayers) {
    toSave.add(hl.nodes.size() + "");
  }

  for (Node n : selected.inputs) {
    toSave.addAll(n.getStringsValue());
  }

  for (hiddenLayer hl : selected.hiddenLayers) {
    for (Node n : hl.nodes) {
      toSave.addAll(n.getStringsValue());
    }
  }

  saveStrings("snakeSelected.txt", toSave.toArray(new String[toSave.size()]));
  println("CREATURE SAVED");
}

void Load() {
  String[] lines = loadStrings("snakeSelected.txt");

  Snake _new = new Snake();

  int numberInputs = Integer.parseInt(lines[0]);
  int numberOfHL = Integer.parseInt(lines[1]);
  ArrayList<Integer> nodesInHLS = new ArrayList<Integer>();
  for (int i = 0; i < numberOfHL; i++) {
    nodesInHLS.add(Integer.parseInt(lines[2+i]));
  }

  _new.topology = new ArrayList<Integer>();
  _new.topology.add(numberInputs);
  for (int hlSize : nodesInHLS) {
    _new.topology.add(hlSize-1);
  }
  _new.topology.add(4);
  _new.InitializeTopology();

  lines = subset(lines, 2 + nodesInHLS.size());
  Node _n;
  
  _new.brain.inputs.clear();
  //inputs
  for (int n = 0; n < numberInputs; n++) {
    _n = new Node();
    _n.weights = new ArrayList<Float>();
    for (int i = 0; i < nodesInHLS.get(0); i++) {
      _n.weights.add(Float.parseFloat(lines[i]));
    }
    _new.brain.inputs.add(_n);
    lines = subset(lines, nodesInHLS.get(0));
  }
  //hidden layers
  for (int hl = 0; hl < numberOfHL; hl++) { //<>//
    _new.brain.hiddenLayers.get(hl).nodes.clear();
    for (int n = 0; n < nodesInHLS.get(hl); n++) {
      _n = new Node();
      _n.weights = new ArrayList<Float>();
      int numberWeights;
      if (nodesInHLS.size() - 1 == hl) {
        numberWeights = _new.topology.get(_new.topology.size() - 1);
      } else {
        numberWeights = nodesInHLS.get(1+hl) - 1;
      }
      for (int i = 0; i < numberWeights; i++) {
        _n.weights.add(Float.parseFloat(lines[i]));
      }
      ((hiddenLayer)_new.brain.hiddenLayers.get(hl)).nodes.add(_n);
      lines = subset(lines, numberWeights);
    }
  }
  loadedToAcquarium = _new;
  loadedToAcquarium.Initialize();
}


void mouseClicked() {
  if (mouseButton == LEFT) {
  } else if (mouseButton == RIGHT) {
  }
}

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
  } else if (key == 'y') { 
    Save();
  } else if (key == 'i') {
    Load();
  }
}
