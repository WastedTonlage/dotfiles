import math
parts = (
    ("A", 0.33333),
    ("B", 0.125),
    ("C", 0.125),
    ("D", 0.125)
 )
output = ""
for y in range(-10, 10):
    for x in range(-10, 10):
        if math.sqrt(pow(x, 2) + pow(y, 2)) > 10:
            output += " "
            continue
        angle = math.atan2(x, y)
        if angle < 0:
            angle += math.tau
        currentPartAngle = 0
        for part in parts:
            partangle = part[1] * math.tau + currentPartAngle
            if angle < partangle:
                output += part[0]
                break
            currentPartAngle = partangle
        continue
    output += "\n"
print(output)
