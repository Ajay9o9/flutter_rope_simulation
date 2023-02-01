// Spring Forces
// https://github.com/Ajay9o9

import 'package:rope_simulation/particle.dart';
import 'package:vector_math/vector_math_64.dart';

class Spring {
  double k;
  double restLength;
  Particle a;
  Particle b;

  Spring(
    this.k,
    this.restLength,
    this.a,
    this.b,
  );

  // what this function does is it calculates the force between the two particles
  // and applies it to both of them in opposite directions so that they are attracted to each other and the spring is stretched
  // the force is calculated using Hooke's law which is F = -kx
  // where k is the spring constant and x is the displacement of the spring from its rest length

  // idea is that string is made of a bunch of particles connected by springs
  void update() {
    Vector2 force = b.position - a.position;
    double x = force.length - restLength;
    force.normalize();
    force *= k * x;
    a.applyForce(force);
    force *= -1;
    b.applyForce(force);
  }
}
