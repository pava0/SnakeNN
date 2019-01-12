class EvolutionManager { //<>//
  
  float softMutationRate = 5f;
  float hardMutationRate = 0.3f;

  float pSumWeight = 1f/100f*softMutationRate;
  float pMultWeight = 1f/100f*softMutationRate;

  float pSignWeight = 1f/100f*hardMutationRate;
  float pNewWeight = 1f/100f*hardMutationRate;
  float pSwapWeight = 0.5f/100f*hardMutationRate;

  float deltaSumWeight = 0.2f;
  float deltaMultWeight = 0.2f;

  int generation = 0;
  
  int actualGeneration = 0;
  int maxGenerations = 2000;

  EvolutionManager() {
  }

  public void sort() {
    //Ordino le creature in base al punteggio
    Collections.sort(bufferSnakes);
    generation++;
  }

  public void killWorst() {
    for (int i = 0; i < (int)Math.pow(numberOfInstances, 2) - (int)Math.pow(numberOfInstances, 2)*0.1f; i++) {
      bufferSnakes.remove(bufferSnakes.size() - 1);
    }
  }

  public void breedBest() {
    int size = bufferSnakes.size();
    float count;
    int totPopulation = 0;

    for (Snake c : bufferSnakes) {
      totPopulation += (float)Math.pow(c.score, 3f);
    }
    while (bufferSnakes.size() < (int)Math.pow(numberOfInstances, 2)) {
      for (int i = 0; i < size; i++) {
        count = (float)((Math.pow(bufferSnakes.get(i).score, 3f) / totPopulation) * ((int)Math.pow(numberOfInstances, 2) / 2));
        for (float f = count; f >= 1; f--) {
          createChild(bufferSnakes.get(i));
          count--;

          if (bufferSnakes.size() >= (int)Math.pow(numberOfInstances, 2)) {
            return;
          }
        }

        if (random(0, 1) <= count) {
          createChild(bufferSnakes.get(i));

          if (bufferSnakes.size() >= (int)Math.pow(numberOfInstances, 2)) {
            return;
          }
        }
      }
    }
  }

  public void createChild(Snake c) {
    Snake child = new Snake();
    child.Clone(c);
    bufferSnakes.add(child);
  }

  public void mutatePopulation() {
    for (Snake c : bufferSnakes) {
      mutate(c);
    }
  }

  public void mutate(Snake c) {

    float _weight;
    //##########ciclo tutti i pesi in tutti i nodi in tutti i livelli######################
    for (int layer = 0; layer < c.brain.topology.size() - 1; layer++) {
      for (int node = 0; node < c.brain.getNumberOfNodesInLayer(layer); node++) {
        for (int weight = 0; weight < c.brain.getNumberOfWeightInNode(layer, node); weight++) {

          _weight = c.brain.getWeightValue(layer, node, weight);

          if (random(1) < pSumWeight) {
            _weight += random(-deltaSumWeight, deltaSumWeight);
            c.brain.setWeightValue(layer, node, weight, _weight);
          }
          if (random(1) < pMultWeight) {
            _weight *= random(1 - deltaMultWeight, 1 + deltaMultWeight);
            c.brain.setWeightValue(layer, node, weight, _weight);
          }
          if (random(1) < pSignWeight) {
            _weight *= -1;
            c.brain.setWeightValue(layer, node, weight, _weight);
          }
          if (random(1) < pNewWeight) {
            _weight = random(-1, 1);
            c.brain.setWeightValue(layer, node, weight, _weight);
          }
          if (random(1) < pSwapWeight) {
            if (c.brain.getNumberOfWeightInNode(layer, node) != 1) {
              int rnd = -1;
              while (rnd != weight) {
                rnd = (int)round(random(0, c.brain.getNumberOfWeightInNode(layer, node)));
              }

              c.brain.swapWeights(layer, node, weight, layer, node, rnd);
            }
          }
        }
      }
    }
  }
  

  public void nextGeneration() {

    sort();
    
    bestSnakes.add(new Snake());
    bestSnakes.get(bestSnakes.size() - 1).Clone(bufferSnakes.get(0));
    bestSnakes.get(bestSnakes.size() - 1).Initialize();
    
    killWorst();
    breedBest();
    mutatePopulation();

    for (Snake s : bufferSnakes) {
      s.Initialize();
    }
  }
}
