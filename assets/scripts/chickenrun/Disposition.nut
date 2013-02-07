class DispositionDef {
    name = null;
    positionX = 0;
    
    constructor(_name, _positionX) {
        name = _name;
        positionX = _positionX;
    }
}

BuildingsDispositionArray <- [
        DispositionDef("building-1.png", -10),
        DispositionDef("building-2.png", 30),
        DispositionDef("building-3.png", 100),
        DispositionDef("building-1.png", 180),
        DispositionDef("building-4.png", 220),
        DispositionDef("building-5.png", 270),
];

HousesDispositionArray <- [
        DispositionDef("house-1.png", 50),
        DispositionDef("house-2.png", 400),
        DispositionDef("house-3.png", 1000),
        DispositionDef("house-4.png", 1500),
        DispositionDef("house-5.png", 1700),
];