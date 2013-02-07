AssetsDef <- {
    car = {
        name = "new-car-sprite.png"
        width = 150
        height = 71
        
        density = 0.8
        friction = 0.7
        restitution = 0.0
        
        anim = {
            destroy = {
                startFrame = 3
                frameCount = 4
                interval = 100
                loop = 1
            }
            run = {
                startFrame = 0
                frameCount = 3
                interval = 100
                loop = -1
            }
        }
    }
    
    sky = {
        name = "sky.png"
    }
    
    mountain = {
        name = "mountain.png"
    }
    
    distantGround = {
        name = "distant-ground.png"
        width = 100
        height = 100
        positionY = 350
    }
    
    ground = {
        name = "road-2.png"
        width = 100
        height = 100
    }
};

