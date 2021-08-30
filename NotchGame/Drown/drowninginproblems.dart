import 'dart:html';
import 'dart:async';

DateTime now = new DateTime.now();

class Problem {
  String id;
  String description;
  Duration duration;
  List<String> solvesProblems = new List<String>();
  List<String> causesProblems = new List<String>();
  Element element;
  bool active = false;
  bool solving = false;
  DateTime solveStart;
  bool solvesAll = false;
  bool removesAll = false;
  Map<String, int> awards = {};
  Map<String, int> costs = {};
  bool solvable = true;
  List<String> requires = [];
  
  Problem(this.id, this.description, this.duration) {
    problems[id] = this;
  }
  
  void solves(String id) => solvesProblems.add(id);
  void causes(String id) => causesProblems.insert(0, id);
  
  void insertAfter(Element element) {
    element.insertAdjacentHtml("afterend", "<div id='$id'></div>");
    setElement(querySelector("#$id"));
  }

  void insertIn(Element element) {
    element.innerHtml="<div id='$id'></div>";
    setElement(querySelector("#$id"));
  }
  
  void setElement(Element element) {
    this.element = element;
    active = true;
    solving = false;
    activeProblems.add(this);
    equipmentUpdated();
  }
  
  void equipmentUpdated() {
    bool fitsRequirements = true;
    requires.forEach((id){
      if (!equipment.containsKey(id)) {
        fitsRequirements = false;
      }
    });
    
    String costString = "";
    if (costs.isNotEmpty) {
      costs.keys.forEach((id){
        if (costString.isNotEmpty) costString+=" ";
        if (costs[id]==1) {
          costString+="-$id";
        } else {
          costString+="-${costs[id]} $id";
        }
      });
      costString=" <span class='cost'>$costString</span>";
    }
    String awardString = "";
    if (awards.isNotEmpty) {
      awards.keys.forEach((id){
        if (awardString.isNotEmpty) awardString+=" ";
        if (awards[id]==1) {
          awardString+="+$id";
        } else {
          awardString+="+${awards[id]} $id";
        }
      });
      awardString=" <span class='award'>$awardString</span>";
    }

    if (canAfford()) {
      this.element.innerHtml = "$description <a href='#' id='${id}_solve'>Solve</a>.$costString$awardString";
      querySelector("#${id}_solve").onClick.listen((t)=>solve());
    } else {
      this.element.innerHtml = "$description [Can't afford]$costString$awardString";
    }
    
    if (!fitsRequirements) {
      remove();
    }
  }
  
  void require(String id) {
    requires.add(id);
  }
  
  void solve() {
    if (!canAfford()) return;
    
    if (costs.isNotEmpty) {
      costs.keys.forEach((id) {
        equipment[id]-=costs[id];
        if (equipment[id]==0) equipment.remove(id);
      });
      updateEquipment();
    }
    
    solving = true;
    solveStart = now;
    tick();
  }
  
  bool canAfford() {
    bool afford = true;
    if (costs.isNotEmpty) {
      costs.keys.forEach((id){
        if (!equipment.containsKey(id)) afford = false;
        else if (equipment[id]<costs[id]) afford = false;
      });
    }
    return afford;
  }
  
  void tick() {
    if (!solving) return;
    
    
    Duration elapsedTime = now.difference(solveStart);
    double progress = elapsedTime.inMilliseconds/duration.inMilliseconds;
    if (progress>1.0) {
      progress = 1.0;
      solved();
    } else {
      element.innerHtml = "$description [${(progress*100).toStringAsFixed(2)}%]";
    }
  }
  
  void solved() {
    solving = false;
    if (removesAll) {
      equipment.clear();
      equipment["Hope"] = 1;
      equipment["Body"] = 1;
    }
    if (awards.isNotEmpty) {
      awards.keys.forEach((id){
        if (!equipment.containsKey(id)) equipment[id]=0;
        equipment[id]+=awards[id];
      });
    }
    updateEquipment();
    solvesProblems.forEach((id){
      if (problems[id].active) {
        problems[id].remove();
      }
    });
    if (solvesAll) {
      new List<Problem>.from(activeProblems).forEach((p) {
        if (p!=this && p.active) {
          p.remove();
        }
      });
    }
    causesProblems.forEach((id){
      if (!problems[id].active) {
        problems[id].insertAfter(element);
      }
    });
    
    if (solvable) remove();
  }
  
  void award(String id, [int quantity = 1]) {
    if (!awards.containsKey(id)) awards[id] = 0;
    awards[id]+=quantity;
  }

  void cost(String id, [int quantity = 1]) {
    if (!costs.containsKey(id)) costs[id] = 0;
    costs[id]+=quantity;
  }
  
  void remove() {
    activeProblems.remove(this);
    element.remove();
    active = false;
    solving = false;
  }
}

Map<String, Problem> problems = {};
Map<String, int> equipment = {};

List<Problem> activeProblems = new List<Problem>();

void main() {
  new Problem("start", "There is nothing.", new Duration(seconds:10))..causes("age0");
  new Problem("age0", "You are not.", new Duration(seconds:5))..causes("age1")..award("Hope");
  new Problem("age1", "You are starting to become.", new Duration(seconds:3))..causes("age2")..award("Body");
  new Problem("age2", "You are.", new Duration(seconds:3))..causes("age3")..award("Life")..causes("learn");
  new Problem("age3", "You are born.", new Duration(seconds:3))..causes("age4")..award("Love")..causes("play");
  new Problem("age4", "You are a toddler.", new Duration(seconds:3))..causes("age5")..award("Integrity")..causes("meetfriend")..cost("Knowledge", 8);
  new Problem("age5", "You are a child.", new Duration(seconds:3))..causes("age6")..award("Loyalty")..cost("Experience", 4)..causes("meetlove")..causes("findwork");
  new Problem("age6", "You are a teenager.", new Duration(seconds:3))..causes("age7")..cost("Broken Heart", 2)..causes("create")..causes("morestuff");
  new Problem("age7", "You are a human.", new Duration(seconds:3))..causes("age8")..cost("Loyalty")..cost("Crushed Dream", 1)..causes("changeworld");
  new Problem("age8", "You are troubled.", new Duration(seconds:3))..causes("age9")..cost("Integrity")..solves("meetfriend")..solves("play")..solves("meetlove")..cost("Lost Ambition");
  new Problem("age9", "You are bitter.", new Duration(seconds:3))..causes("age10")..cost("Love")..solves("create")..solves("meetlove")..solves("makelove")..solves("friend")..solves("learn")..cost("Memory", 10);
  new Problem("age10", "You are starting to accept.", new Duration(milliseconds:800))..causes("age11")..cost("Life")..solvesAll=true..removesAll=true;
  new Problem("age11", "You are dead.", new Duration(seconds:60))..causes("age12")..cost("Body");
  new Problem("age12", "You are forgotten.", new Duration(seconds:60*5))..causes("age13")..cost("Hope");
  new Problem("age13", "There is nothing.", new Duration(seconds:60*10));
  
  new Problem("play", "You need to play.", new Duration(seconds:2))..solvable=false..award("Memory");
  new Problem("findwork", "You need to find a job.", new Duration(seconds:8))..award("Job")..causes("work");
  new Problem("work", "You need to go to work.", new Duration(seconds:4))..award("Money")..award("Stress")..solvable=false..causes("relax")..causes("betterjob")..require("Job");
  new Problem("relax", "You need to relax.", new Duration(seconds:8))..solvable=false..cost("Stress")..require("Stress");
  new Problem("meetfriend", "You need more friends.", new Duration(seconds:8))..award("Friend")..solvable=false..causes("friend");
  new Problem("friend", "You need to see a friend.", new Duration(seconds:4))..solvable=false..award("Memory")..causes("moveon")..require("Friend");
  new Problem("moveon", "You need to move on.", new Duration(seconds:2))..cost("Friend")..award("Experience");
  new Problem("betterjob", "You need a better job.", new Duration(seconds:6))..cost("Knowledge", 4)..solvable=false..require("Job")..award("Respect");
  new Problem("learn", "You need learn.", new Duration(seconds:2))..award("Knowledge")..solvable=false;
  new Problem("meetlove", "You need to find a lover.", new Duration(seconds:6))..causes("makelove")..award("Lover");
  new Problem("makelove", "You need to make love.", new Duration(seconds:4))..solvable=false..award("Memory")..causes("loselover")..require("Lover");
  new Problem("loselover", "You need to feel accepted.", new Duration(seconds:2))..cost("Lover")..award("Broken Heart")..causes("meetlove")..solves("makelove")..award("Experience");
  new Problem("create", "You need to create.", new Duration(seconds:5))..solvable=false..award("Project")..causes("fail")..cost("Money", 4);
  new Problem("fail", "You need to fail.", new Duration(seconds:5))..cost("Project")..award("Crushed Dream")..award("Memory");
  new Problem("changeworld", "You need to try harder.", new Duration(seconds:10))..award("Lost Ambition")..cost("Respect",  5)..cost("Stuff", 10);
  new Problem("morestuff", "You need more stuff.", new Duration(seconds:2))..award("Stuff")..cost("Money")..solvable=false;
  
  problems["start"].insertIn(querySelector("#problems"));
  new Timer.periodic(const Duration(milliseconds: 16), (t)=>tick());
}

void updateEquipment() {
  if (equipment.isEmpty) {
    querySelector("#equipment").innerHtml = "";
  } else {
    String inventoryList = "";
    equipment.keys.forEach((key){
      if (inventoryList.isNotEmpty) inventoryList+="<br>";
      if (equipment[key]==1) {
        inventoryList+="$key";
      } else {
        inventoryList+="${equipment[key]} $key";
      }
    });
    querySelector("#equipment").innerHtml = "You have:<br>$inventoryList";
  }
  new List<Problem>.from(activeProblems).forEach((e)=>e.equipmentUpdated());
}

void tick() {
  now = new DateTime.now();
  new List<Problem>.from(activeProblems).forEach((e)=>e.tick());
}
