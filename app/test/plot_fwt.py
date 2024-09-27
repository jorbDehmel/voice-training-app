'''
Plots data outputted by dart when analyzing a WAV file.
'''

import sys
from typing import List, Iterable
from matplotlib import pyplot as plt
from matplotlib import animation


def load_file(fp: str) -> List[List[float]]:
    '''
    Loads the given file into processable data
    '''

    out: List[List[float]] = []
    lines: List[str] = []

    with open(fp, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    out = [[float(i) for i in line[1:-2].split(', ')]
           for line in lines]

    return out


if __name__ == '__main__':

    assert len(sys.argv) == 2
    name: str = sys.argv[1]

    n: int = -1
    n_bars: int = -1
    min_y: float = 999999.0
    max_y: float = -min_y

    print(f'Loading file {name}...')
    data: List[List[float]] = load_file(name)

    print('Analyzing items...')
    n = len(data)
    n_bars = len(data[0])

    for row in data:
        for item in row:
            if item < min_y:
                min_y = item
            elif item > max_y:
                max_y = item

    def fn(i: int) -> List[float]:
        '''
        Yields the value of the bars at the given frame
        '''

        return data[i - 1]

    fps: int = 200
    x: Iterable = range(n_bars)
    fig = plt.figure()
    axes = fig.add_subplot(1, 1, 1)
    axes.set_ylim(min_y, max_y)
    bars = plt.bar(x, fn(0))

    def animate(i: int) -> None:
        '''
        Animation function, for the frame i.
        '''

        y = fn(i + 1)
        for i, b in enumerate(bars):
            b.set_height(y[i])

    print(f'This video will be {n / fps} seconds long')

    print('Animating...')
    anim = animation.FuncAnimation(
        fig, animate, repeat=False, blit=False, frames=n,
        interval=100)

    print('Saving...')
    def progress_update(
            current_frame: int, total_frames: int) -> None:
        p: float = \
            round(100.0 * current_frame / total_frames, 2)
        print(f'{p}% done...')
    anim.save(f'{name}.mp4',
              writer=animation.FFMpegWriter(fps=fps),
              progress_callback=progress_update)
    print('Done!')
