class Snake implements Comparable { //<>// //<>//
  public PVector food;
  public int foodEaten;
  public int stepsTaken;
  public PVector direction;
  public PVector prevDirection = direction;
  public ArrayList<PVector> body;
  public boolean isDead = false;

  int _gen;

  float closerDistanceToActualFood;
  float score;

  public Brain brain;

  Snake() {
    body = new ArrayList<PVector>();
    Initialize();
    InitializeTopology();

    _gen = evolManager.generation;
  }

  @Override
    public int compareTo(Object _snake) {
    //return ((Creature)_creature).score - score;
    return ((Snake)_snake).score < score ? -1 
      : ((Snake)_snake).score > score ? 1 
      : 0;
  }
  @Override
    public String toString() {
    return Float.toString(score);
  }

  void Initialize() {
    isDead = false;
    foodEaten = 0;
    stepsTaken = 0;
    food = foods.get(foodEaten);
    closerDistanceToActualFood = Float.MAX_VALUE;

    body.clear();
    body.add(new PVector((int)Math.floor((sideOfPlay)/2), (int)Math.floor((sideOfPlay)/2)));
    direction = new PVector(0, -1);
    prevDirection = direction.copy();
    body.add(PVector.sub(body.get(0), direction));
  }

  void InitializeTopology() {
    brain = new Brain(new ArrayList < Integer >() {
      {
        add((int)Math.pow(sideOfPlay, 2));
        add(10);
        add(4);
      }
    }
    );
  }

  void Think() {
    if (isDead == false) {
      ArrayList<Float> inputs = new ArrayList<Float>();

      //Aggiungo i delta dal muro
      for (int i = 0; i < Math.pow(sideOfPlay, 2); i++) {
        inputs.add(0f);
      }
      for (PVector p : body) {
        int index = (int)p.x + (int)p.y * sideOfPlay;
        inputs.set(index, 0.1f);
      }
      int _pos = (int)body.get(0).x + (int)body.get(0).y * sideOfPlay;
      inputs.set(_pos, 1f);

      food = foods.get(foodEaten);
      if (food.x < 0 || food.y < 0) {
        print("foodEaten: " + foodEaten + " x: " + food.x + " y: " + food.y);
      }

      int _food = (int)(food.x + food.y * sideOfPlay);
      inputs.set(_food, 10f);

      brain.initiate(inputs);
      brain.calculate();

      //output
      int indexDirection = - 1;
      float lastMax = Float.MIN_VALUE;
      for (int i = 0; i < brain.outputs.size(); i++) {
        if (brain.outputs.get(i) > lastMax) {
          lastMax = brain.outputs.get(i);
          indexDirection = i;
        }
      }

      switch(indexDirection) {
      case 0:
        direction = new PVector(0, 1);
        break;
      case 1:
        direction = new PVector(1, 0);
        break;
      case 2:
        direction = new PVector(0, -1);
        break;
      case 3:
        direction = new PVector(-1, 0);
        break;
      }
    }
  }


  void Move() {
    if (PVector.dist(PVector.add(body.get(0), direction), body.get(1)) == 0) {
      direction = prevDirection;
    }
    if (body.get(0).x + direction.x >= sideOfPlay || body.get(0).x + direction.x < 0 || body.get(0).y + direction.y >= sideOfPlay || body.get(0).y + direction.y < 0) {
      isDead = true;
    }

    if (foodEaten >= numberOfFoods - 1) {
      isDead = true;
    }

    if (isDead == false) {

      for (PVector v : body) {
        if (PVector.dist(PVector.add(body.get(0), direction), v) == 0 ) {
          isDead = true;
        }
      }

      if (stepsTaken > maxNumberOfStepBeforeKill) {
        isDead = true;
        return;
      }

      //modifica la posizione dei pezzi del corpo
      for (int i = body.size() - 1; i >= 0; i--) {
        if (i == 0) {
          body.get(0).add(direction);
        } else {
          PVector prev = body.get(i-1); 
          body.set(i, prev.copy());
        }
      }
      stepsTaken++;

      if (PVector.dist(body.get(0), food) == 0) { 
        if (foodEaten < numberOfFoods) {
          body.add(PVector.add(body.get(body.size() - 1), PVector.sub(body.get(body.size() - 1), body.get(body.size() - 2))));

          foodEaten++;
          stepsTaken = 0;

          closerDistanceToActualFood = Float.MAX_VALUE;
          food = foods.get(foodEaten);
        } else {
          isDead = true;
        }
      }

      prevDirection = direction;
    }

    updateScore();
  }

  public void updateScore() {
    if (PVector.dist(body.get(0), food) < closerDistanceToActualFood) {
      closerDistanceToActualFood = PVector.dist(body.get(0), food);
    }

    score = (foodEaten * pointsForFood) + (sideOfPlay / closerDistanceToActualFood / 2);
  }

  public void Clone(Snake s) {
    brain.inputs = new ArrayList<Node>(s.brain.inputs.size());
    for (Node n : s.brain.inputs) {
      Node _newN = new Node(n.weights.size());
      _newN.clone(n);
      brain.inputs.add(_newN);
    }

    brain.outputs = new ArrayList<Float>(s.brain.outputs.size());
    for (Float n : s.brain.outputs) {
      brain.outputs.add(n);
    }

    brain.hiddenLayers = new ArrayList<hiddenLayer>(s.brain.hiddenLayers.size());
    for (hiddenLayer h : s.brain.hiddenLayers) {
      hiddenLayer _newH = new hiddenLayer();
      _newH.clone(h);
      brain.hiddenLayers.add(_newH);
    }

    brain.topology = new ArrayList<Integer>(s.brain.topology.size());
    for (Integer n : s.brain.topology) {
      brain.topology.add(n);
    }
  }

  void Draw() {
    PVector _tmpPos = new PVector();

    for (int i = 0; i < body.size(); i++) {
      if (isDead == false) {
        if (i == 0) {
          fill(0, 128, 255);
        } else {
          fill(0, 255, 0);
        }
      } else {
        fill(128);
      }

      _tmpPos.x = body.get(i).x * sideOfASquare;
      _tmpPos.y = body.get(i).y * sideOfASquare;
      rect(_tmpPos.x, _tmpPos.y, sideOfASquare, sideOfASquare);
    }

    fill(255, 0, 0);
    _tmpPos.x = food.x * sideOfASquare;
    _tmpPos.y = food.y * sideOfASquare;
    rect(_tmpPos.x, _tmpPos.y, sideOfASquare, sideOfASquare);

    fill(255);
  }
}
