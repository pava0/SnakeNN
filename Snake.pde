class Snake implements Comparable { //<>//
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
    body.add(new PVector((int)Math.floor((sideOfPlay-1)/2), (int)Math.floor((sideOfPlay-1)/2)));
    direction = new PVector(0, -1);
    prevDirection = direction.copy();
    body.add(PVector.sub(body.get(0), direction));
  }

  void InitializeTopology() {
    brain = new Brain(new ArrayList < Integer >() {
      {
        add((int)Math.pow(sideOfPlay, 2));
        add(numberOfNodeInHL);
        add(4);
      }
    }
    );
  }

  void Think() {
    if (isDead == false) {
      ArrayList<Double> inputs = new ArrayList<Double>();
      
      for (int i = 0; i < Math.pow(sideOfPlay, 2); i++) {
        inputs.add(0d);
      }
      
      for (PVector p : body) {
        int index = (int)p.x + (int)p.y * sideOfPlay;
        if (p.x < 0 || p.y < 0) {
          for (int i = 0; i < body.size(); i++) {
            println("X: " + body.get(i).x + " Y: " + body.get(i).y);
          }
        }
        inputs.set(index, 0.1d);
      }
      
      int _pos = (int)body.get(0).x + (int)body.get(0).y * sideOfPlay;
      inputs.set(_pos, 1d);

      food = foods.get(foodEaten);
      if (food.x < 0 || food.y < 0) {
        print("foodEaten: " + foodEaten + " x: " + food.x + " y: " + food.y);
      }

      int _food = (int)(food.x + food.y * sideOfPlay);
      inputs.set(_food, 10d);

      brain.initiate(inputs);
      brain.calculate();

      //output
      int indexDirection = - 1;
      Double lastMax = Double.MIN_VALUE;
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

      boolean addFood = false;
      PVector lastBody = null;
      PVector prev = null;
      //modifica la posizione dei pezzi del corpo
      for (int i = 0; i < body.size(); i++) {
        if (i == 0) {
          prev = body.get(0).copy();
          body.get(0).add(direction);

          if (PVector.dist(body.get(0), food) == 0) { 
            addFood = true;
            lastBody = body.get(body.size() - 1);
          }
        } else {
          PVector tmp = prev.copy();
          ;
          prev = body.get(i).copy();
          ;
          body.set(i, tmp);
        }
      }

      if (addFood == true) {
        if (foodEaten < numberOfFoods) {
          body.add(lastBody);

          foodEaten++;
          stepsTaken = 0;

          closerDistanceToActualFood = Float.MAX_VALUE;
          food = foods.get(foodEaten);
        } else {
          isDead = true;
        }
      }
      prevDirection = direction;
      stepsTaken++;
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

    brain.outputs = new ArrayList<Double>(s.brain.outputs.size());
    for (Double n : s.brain.outputs) {
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

    color bodyPiece;

    for (int i = 0; i < body.size(); i++) {
      if (isDead == false) {
        if (i == 0) {
          bodyPiece = color(0, 128, 255);
        } else {
          bodyPiece = color(0, 255, 0);
        }
      } else {
        bodyPiece = color(128);
      }

      _tmpPos.x = body.get(i).x * sideOfASquare;
      _tmpPos.y = body.get(i).y * sideOfASquare;

      fill(bodyPiece);
      rect(_tmpPos.x, _tmpPos.y, sideOfASquare, sideOfASquare);

      if (i == 0) {
        fill(0);
        text(Math.round(score/pointsForFood), _tmpPos.x + sideOfASquare / 2, _tmpPos.y + sideOfASquare / 2 + 3);
      }
    }

    fill(255, 0, 0);
    _tmpPos.x = food.x * sideOfASquare;
    _tmpPos.y = food.y * sideOfASquare;
    rect(_tmpPos.x, _tmpPos.y, sideOfASquare, sideOfASquare);

    fill(255);
  }
}
