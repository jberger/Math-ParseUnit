use strict;
use warnings;

use Test::More;

use Math::ParseUnit::Tokenizer qw/tokenize/;

my @tests = (
  # Numbers
  ['+14' => [['INTEGER', '+14']]],
  ['-1.6e-19' => [['NUMBER','-1.6e-19']]],

  # Numbers with Units
  ['-1.6e-19 C' => [['NUMBER','-1.6e-19'],
                    ['WORD'  , 'C'      ]]
  ],
  [' 5 J s' => [['INTEGER', '5'], 
                ['WORD'   , 'J'], 
                ['WORD'   , 's']]
  ],

  # Numbers with compound units (multiplicative)
  [' 5 J*s' => [['INTEGER', '5'],
                ['WORD'   , 'J'],
                ['MULT_OP', '*'],
                ['WORD'   , 's']]
  ],
  [' 5 J x s' => [['INTEGER' , '5'],
                  ['WORD'   , 'J'],
                  ['MULT_OP', '*'],
                  ['WORD'   , 's']]
  ],
  [' 5 J times s' => [['INTEGER', '5'],
                      ['WORD'   , 'J'],
                      ['MULT_OP', '*'],
                      ['WORD'   , 's']]
  ],

  # Numbers with compound units (division)
  [' 3e8 m/s' => [['NUMBER' , '3e8'],
                  ['WORD'   , 'm'],
                  ['MULT_OP', '/'],
                  ['WORD'   , 's']]
  ],
  [' 8 m per s' => [['INTEGER', '8'],
                    ['WORD'   , 'm'],
                    ['MULT_OP', '/'],
                    ['WORD'   , 's']]
  ],
  [' 8 m over s' => [['INTEGER', '8'],
                     ['WORD'   , 'm'],
                     ['MULT_OP', '/'],
                     ['WORD'   , 's']]
  ],
  [' 8 m divides s' => [['INTEGER', '8'],
                        ['WORD'   , 'm'],
                        ['MULT_OP', '/'],
                        ['WORD'   , 's']]
  ],
  [' 8 m divided by s' => [['INTEGER', '8'],
                           ['WORD'   , 'm'],
                           ['MULT_OP', '/'],
                           ['WORD'   , 's']]
  ],
  [' 8 m upon s' => [['INTEGER', '8'],
                     ['WORD'   , 'm'],
                     ['MULT_OP', '/'],
                     ['WORD'   , 's']]
  ],

  # numbers with complicated units
  ['1.4 kg m / s' => [['NUMBER' , '1.4'],
                      ['WORD'   , 'kg' ],
                      ['WORD'   , 'm'  ],
                      ['MULT_OP', '/'  ],
                      ['WORD'   , 's'  ]]
  ],
  ['-9.8 kg m / s / s' => [['NUMBER' , '-9.8'],
                           ['WORD'   , 'kg'  ],
                           ['WORD'   , 'm'   ],
                           ['MULT_OP', '/'   ],
                           ['WORD'   , 's'   ],
                           ['MULT_OP', '/'   ],
                           ['WORD'   , 's'   ]]
  ],
  ['-9.8 kg m / s ** 2' => [['NUMBER' , '-9.8'],
                            ['WORD'   , 'kg'  ],
                            ['WORD'   , 'm'   ],
                            ['MULT_OP', '/'   ],
                            ['WORD'   , 's'   ],
                            ['EXP_OP' , '**'  ],
                            ['INTEGER', '2'   ]]
  ],
  ['-9.8 kg m per s squared' => [['NUMBER'    , '-9.8'],
                                 ['WORD'      , 'kg'  ],
                                 ['WORD'      , 'm'   ],
                                 ['MULT_OP'   , '/'   ],
                                 ['WORD'      , 's'   ],
                                 ['NUM_EXP_OP', '2'   ]]
  ],
);

foreach my $test (@tests) {
  is_deeply(tokenize($test->[0]), $test->[1], "Properly tokenized $test->[0]");
}

done_testing;

