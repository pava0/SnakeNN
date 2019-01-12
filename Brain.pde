class Brain { //<>//

  ArrayList <Node> inputs; 
  ArrayList <Float> outputs; 

  ArrayList <hiddenLayer> hiddenLayers; 
  ArrayList <Integer> topology;

  Brain(ArrayList <Integer> _topology) {
    this.topology = _topology;
    inputs = new ArrayList < Node > (); 
    outputs = new ArrayList < Float > (); 

    hiddenLayers = new ArrayList <hiddenLayer> (); 

    for (int layer = 0; layer < topology.size(); layer++) {
      if (layer == 0) {//inputs
        for (int i = 0; i < topology.get(layer) + 1; i++) {
          inputs.add(new Node(topology.get(layer + 1)));
        }
        inputs.get(inputs.size()-1).value = 1f;
      } else if (layer == topology.size() - 1) {
        for (int i = 0; i < topology.get(layer); i++) {
          outputs.add(0f);
        }
      } else {
        hiddenLayers.add(new hiddenLayer(topology.get(layer) + 1, topology.get(layer + 1)));
      }
    }
  }

  public void initiate(ArrayList <Float> _inputs) {
    Node _n;
    for (int i = 0; i < _inputs.size(); i++) {
      _n = inputs.get(i);
      _n.value = _inputs.get(i);
    }
  }

  public Node getNode(int layer, int node) {
    Node _n;
    if (layer == 0) {
      _n = inputs.get(node);
    } else {
      hiddenLayer HL = hiddenLayers.get(layer - 1);
      _n = HL.nodes.get(node);
    }
    return _n;
  }

  public int getNumberOfNodesInLayer(int layer) {
    if (layer == 0) return inputs.size();
    else {
      return hiddenLayers.get(layer - 1).nodes.size();
    }
  }

  public float getWeightValue(int layer, int node, int nWeight) {
    return getNode(layer, node).weights.get(nWeight);
  }

  public void setWeightValue(int layer, int node, int nWeight, float value) {
    getNode(layer, node).weights.set(nWeight, value);
  }

  public  void swapWeights(int layer1, int node1, int nWeight1, int layer2, int node2, int nWeight2) {
    float _temp = getWeightValue(layer2, node2, nWeight2);
    setWeightValue(layer2, node2, nWeight2, getWeightValue(layer1, node1, nWeight1));
    setWeightValue(layer1, node1, nWeight1, _temp);
  }

  public int getNumberOfWeightInNode(int layer, int node) {
    Node _n;
    if (layer == 0) {
      _n = inputs.get(node);
    } else {
      hiddenLayer HL = hiddenLayers.get(layer - 1);
      _n = HL.nodes.get(node);
    }
    return _n.weights.size();
  }


  public void calculate() {
    for (int layer = 0; layer < hiddenLayers.size(); layer++) {
      for (int node = 0; node < getNumberOfNodesInLayer(layer + 1); node++) { //+1 perché il layer 0 è l'input
        float _value = 0;

        if (node != getNumberOfNodesInLayer(layer + 1) - 1) {
          for (int nodeBefore = 0; nodeBefore < getNumberOfNodesInLayer(layer); nodeBefore++) {
            _value += getNode(layer, nodeBefore).getSignal(node);
          }

          _value = 1f/(1f + (float)Math.exp(-_value));
        } else {
          _value = 1;
        }

        getNode(layer + 1, node).value = _value;
      }
    }

    for (int output = 0; output < outputs.size(); output++) {
      outputs.set(output, 0f);
      float _value = 0;

      for (int node = 0; node < getNumberOfNodesInLayer(hiddenLayers.size()); node++) {
        _value += getNode(hiddenLayers.size(), node).getSignal(output);
      }

      _value = 1f/(1f + (float)Math.exp(-_value));
      outputs.set(output, _value);
    }
  }
}
class Node {
  public Float value; 
  public ArrayList <Float> weights; 

  Node() {
  }
  Node(int numberOfWeightsForNode) {
    weights = new ArrayList <Float> (); 
    for (int i = 0; i < numberOfWeightsForNode; i++) {
      weights.add(random(-1, 1));
    }
  }

  public float getSignal(int numberWeight) {
    return value * weights.get(numberWeight);
  }

  public void clone(Node n) {
    this.value = n.value;
    weights = new ArrayList<Float>();
    for (Float f : n.weights) {
      weights.add(f);
    }
  }
  
  public ArrayList<String> getStringsValue() {
    ArrayList<String> string = new ArrayList<String>();
    
    string.add(value.toString());
    for(Float f : weights) {
      string.add(f.toString());
    }
    
    return string;
  }
}

class hiddenLayer {
  public ArrayList < Node > nodes; 

  hiddenLayer() {
  }
  hiddenLayer(int numberOfNodesPerHL, int numberOfWeight) {
    nodes = new ArrayList < Node > (); 
    for (int i = 0; i < numberOfNodesPerHL; i++) {
      nodes.add(new Node(numberOfWeight));
    }
  }

  public float getSignal(int numberNode, int numberWeight) {
    return nodes.get(numberNode).getSignal(numberWeight);
  }

  public void clone(hiddenLayer h) {
    nodes = new ArrayList<Node>();
    for (Node n : h.nodes) {
      Node _new = new Node();
      _new.clone(n);
      this.nodes.add(_new);
    }
  }
}
