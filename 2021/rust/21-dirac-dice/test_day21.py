from itertools import product

P1, P2 = 0, 1


class Die:
    def __init__(self):
        self.rolls = 0
        self.sides = 100

    def roll(self, rolls=1):
        result = []
        for _ in range(rolls):
            self.rolls += 1
            v = self.rolls
            while v > self.sides:
                v -= self.sides
            result.append(v)
        return result


class Puzzle:
    def __init__(self, player1: int, player2: int):
        self.positions, self.scores = [player1, player2], [0, 0]
        self.die = Die()
        self.curr = 0

    def loser(self):
        return 0 if self.curr == 1 else 1

    def play(self, turns=10_000):
        for _ in range(turns):
            v = self.die.roll(3)
            self.positions[self.curr] += sum(v)
            while self.positions[self.curr] > 10:
                self.positions[self.curr] -= 10
            self.scores[self.curr] += self.positions[self.curr]
            print(f'Player {self.curr+1} rolls {v}',
                  f'and moves to space {self.positions[self.curr]}',
                  f'for a total score of {self.scores[self.curr]}')
            if self.scores[self.curr] >= 1000:
                break
            self.curr = P1 if self.curr == P2 else P2


def get_outcomes():
    result = {}
    for r1, r2, r3 in list(product('123', repeat=3)):
        v = int(r1) + int(r2) + int(r3)
        result[v] = 1 + result.get(v, 0)
    return result


def wrap(v, pos, last=10):
    pos += v
    return pos if pos <= last else pos - last


class Game:
    def __init__(self):
        pass

    def play_many(self, player1: int, player2: int) -> int:
        turn, wins, outcomes = 0, [0, 0], get_outcomes()

        u = {  # we start with one universe:
            (player1, 0, player2, 0): 1
        }

        # turn 1 (P1)
        # 3 rolls: 1 -> 27 universes
        # 7 outcomes:
        # v+=3 in 1 universe
        # v+=4 in 3 universes
        # v+=5 in 6 universes
        # v+=6 in 7 universes
        # v+=7 in 6 universes
        # v+=8 in 3 universes
        # v+=9 in 1 universe

        print()
        while len(u) > 0:
            for curr in [P1, P2]:
                turn += 1
                evolutions = {}
                for universe, count in u.items():
                    # 1 -> 27 new universes
                    for v, inc in outcomes.items():
                        p1, s1, p2, s2 = universe
                        universes = count * inc
                        if curr == P1:
                            p1 = wrap(v, p1)
                            s1 += p1
                            if s1 >= 21:
                                wins[P1] += universes
                                continue
                        else:
                            p2 = wrap(v, p2)
                            s2 += p2
                            if s2 >= 21:
                                wins[P2] += universes
                                continue
                        evolution = (p1, s1, p2, s2)
                        if evolutions.get(evolution) is None:
                            evolutions[evolution] = 0
                        # universes converge:
                        evolutions[evolution] += universes
                print(f'turn: {turn:2d}', f'player: {curr} '
                      f'universe count {len(u):5d} to {len(evolutions):5d}')
                u = evolutions
        return max(wins)


def test_die():
    die = Die()
    assert die.roll(1) == [1]
    assert die.roll(1) == [2]
    assert die.roll(1) == [3]
    assert die.roll(3) == [4, 5, 6]
    die = Die()
    die.roll(99)
    assert die.roll(1) == [100]
    assert die.roll(1) == [1]
    assert die.rolls == 101


def test_wrap():
    assert wrap(1, 1) == 2
    assert wrap(1, 9) == 10
    assert wrap(1, 10) == 1


def test_sample():
    p = Puzzle(4, 8)
    p.play(turns=1)
    assert p.die.rolls == 3
    assert p.scores[P1] == 10
    p.play()
    assert p.scores[p.loser()] == 745
    assert p.die.rolls == 993


def test_input():
    p = Puzzle(8, 1)
    p.play()
    result = p.scores[p.loser()] * p.die.rolls
    assert result == 518418


def test_universe_sample():
    g = Game()
    winner_wins = g.play_many(4, 8)
    assert winner_wins == 444356092776315


def test_universe_input():
    g = Game()
    winner_wins = g.play_many(8, 1)
    assert winner_wins == 116741133558209

if __name__ == '__main__':
    test_universe_sample()