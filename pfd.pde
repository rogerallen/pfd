// Prime factorization diagram
//
// Copyright (c) 2012 John Graham-Cumming
//
// Draws a picture of the numbers 1 to 100 as a square.  Each number
// is represented by a circle broken up into arcs of equal size.  Each
// arc represents a prime factor of the number such that all the arcs
// together form the original number.  Each prime is given a unique
// color.
//
// Inspired by the prime factorization sweater:
// http://sonderbooks.com/blog/?p=843

// I found the distinct-colors palette too distracting.
// So, I'm trying out some other palettes.  Personally, I think
// the green/blue palette allows me to concentrate more on the 
// patterns and be less distracted by all the colors.
int PALETTE = 2; // choose your palette from the following 

int[][] colors = {
 // 48 distinct RGB colors generated using the generating service on
 // http://phrogz.net/css/distinct-colors.html.  This tries to find
 // visually distinct colors that humans will be able to distinguish.
 // palette 0: 48? this is only 43 colors.
 { #ff0000, #e5b073, #73ff40, #23698c, #312040, #a62929,
   #fff240, #00cc88, #80b3ff, #cc00a3, #e6b4ac, #5c6633, #6cd9d2, #00004d,
   #ff0066, #cc5200, #e1ffbf, #1a3331, #1f00e6, #b3597d, #593000, #338000,
   #00ccff, #986cd9, #401016, #1784e3, #52ab44, #ffad99, #ab22a2, #77b2c7,
   #141f0f, #ab2611, #bb00ff, #002b3b, #e5ffb2, #572323, #cf99ff, #00bbff,
   #4d5734, #1f0303, #150c1f, #17d5e3, #a6e300 },

 // 48 color paletts from http://tools.medialab.sciences-po.fr/iwanthue/
 // 1 : a bit pastel & "easter", but more lovely than above
 { #D4EF63, #EEBDF6, #43CFBC, #ECA87B, #70F9A4, #6ECEF2,
   #E1E59B, #FBD052, #C9BCC7, #97C49C, #F29EBD, #ACECE6, #8CD370, #A6B0E8,
   #F69E96, #E5B664, #52D199, #B5F0A0, #AEC8E5, #3CF9C3, #5DDBE6, #D8D664,
   #F2E651, #A2C67B, #E0F68F, #B1EEC9, #BEB974, #DFCAEF, #F5AE4F, #5BF2E7,
   #E8B1BF, #8BCCBC, #BBD7DD, #BCE4A9, #74DC87, #B3DE6F, #E6A1D6, #D6BE4E,
   #8BCAD1, #89D38F, #A0F484, #6CEAC7, #7AF2B3, #F1D4E0, #7CD9AA, #DBBC78,
   #CDAED5, #C4CA75 },
 // 2 : simpler green/blue "ocean" palette
 { #8DDEE9, #39E450, #679655, #43F3B4, #3AA6E9, #479C8F,
   #B0F496, #5F90AE, #6EC895, #3FF4DC, #41BE51, #2EED81, #8CC5ED, #38B36A,
   #8DEEC5, #50B4BA, #7DC36D, #87D8C9, #77EE6C, #6FF195, #4D9769, #4A9D4B,
   #4ADBF4, #40B7E5, #AEDA8D, #59E1DB, #84E37A, #95E7A5, #41A2C2, #34B3A0,
   #88B3CC, #61AD89, #569BA6, #31C192, #54DAB6, #60C2DE, #4798CC, #3ADD91,
   #8FC692, #58CE8D, #7AF2B3, #73AF6E, #6DEE80, #74DC87, #6FA8A8, #9ADF84,
   #1D8FAF, #3F8EA0},
 // 3 : red/orange if that's your thing
 { #E1704E, #F8B010, #A27C62, #C18E3F, #E9B684, #C86B1B,
   #F9A748, #CB8763, #F59251, #D19822, #E49B62, #B97430, #F8BC5C, #ED752E,
   #C26C53, #ED9422, #CD7D4D, #CA8025, #D36232, #B4811D, #F4B536, #E88D6E,
   #EF654B, #B7884C, #CE7236, #E9A279, #E4AF6D, #CB9B6D, #DF944B, #A67B52,
   #E0A855, #EB8C5E, #E2A841, #EB7642, #B47452, #AB7B2E, #E99339, #F7A75B,
   #DF7E2D, #C56C43, #B77442, #B38865, #BB7319, #D1795E, #F17D59, #D26344,
   #E68546, #C8803A }
};

// This is the size of the square on which the prime factorization is
// drawn.  This can be made much larger than the screen for saving a
// large file using saveFrame()

int side = 1024;

// When set to true the factors are printed inside the circles,
// otherwise just colors are used

boolean number = true;

// I do everything in setup() because there's no animation and
// therefore no reason to have code in draw()

void setup() {
    size(side, side);
    background(255);
    stroke(255);
    strokeWeight(2);
    smooth();
    textAlign(CENTER, CENTER);

// "square" sets the number of circles on a side, i.e. 10 creates
// a 10x10 square with 100 circles.

    int square = 12;
    
// Create a grid of circles.
    
    int[] primes = new int[square * square];
    int space = side/square - 2;
    int used = 0;
  
    for (int c = 0; c < square; c++ ) {
        for (int r = 0; r < square; r++ ) {
          int n = r+1 + c*square;
          if ( n != 1 ) {
            
            // Factorize the number into its prime factors and
            // determine if it was itself prime.  If so, then assign
            // the next color available to this number for future use.
            
            int[] f = factor(n);
            
            if ( f.length == 1 ) {
              primes[n] = used;
              used += 1;              
            }
            
            float start_angle = PI / 4;
            float angle = start_angle;
            float per_factor = (2 * PI) / f.length;
            float x = space*(r+0.5);
            float y = space*(c+0.5);
            
            // First draw the arcs themselves with the right colors
            // based on the prime factor each represents.  Then draw
            // white lines across the circle that break up the arcs
            // and (if necessary) add the number itself.
            
            for ( int i = 0; i < f.length; i++ ) {
              fill(colors[PALETTE][primes[f[i]]]);
              arc(x, y, space, space, angle, angle+per_factor);
              angle += per_factor;
            }
            
            if ( f.length > 1 ) {
              angle = start_angle;
              for ( int i = 0; i < f.length; i++ ) {
                line( x, y, x + space/2 * cos(angle), y + space/2.0 *
		      sin(angle) );
                line( x, y, x + space/2 * cos(angle+per_factor), 
                  y + space/2.0 * sin(angle+per_factor) );
                
                if ( number ) {
                  opposite(colors[PALETTE][primes[f[i]]]);
                  text(f[i], x + space/4*cos(angle+per_factor/2),
                    y + space/4*sin(angle+per_factor/2));
                }
                
                angle += per_factor;
              }
            } else {
              if ( number ) {
                opposite(colors[PALETTE][primes[n]]);
                text(n, x, y);
              }
            }
          } else {
            if ( number ) {
              opposite(#FFFFFF);
              text(1, space/2, space/2);
            }
          }
        }
    }
    
    saveFrame();
}

// factor: return an ordered list (smallest to largest) of the prime
// factors of an integer.
int[] factor(int n) {
  int factors[] = new int[0];
  
  int d = 2;
  
  while (n > 1) {
    while (n % d == 0) {
      factors = append(factors, d);
      n /= d;
    }
    d += 1;
  }
    
  return factors;
}

// opposite: set the current fill color to the 'opposite' of the
// passed in color so that it can be seen on top of it. It does this
// by calculating the Euclidean distance of the color from white (255,
// 255, 255) and having a cut off the determines whether to display
// text in white or black.
void opposite(int c) {
  float distance = sqrt(red(c)*red(c)+green(c)*green(c)+blue(c)*blue(c));

  if ( distance < 250 ) {
    fill(255);
  } else {
    fill(0);
  }
}
