'''
Plots data outputted by dart when analyzing a WAV file.
'''

import sys
import subprocess
from typing import List, Iterable
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation
from pywt import dwt, Wavelet


# The number of data points per data segment
SEGMENT_LENGTH: int = 512

# The number of segments to average per reading
SKIP: int = 10


def load_file(fp: str) -> List[List[float]]:
    '''
    Loads the given file into graphable data.

    :param fp: The .wav filepath to load from
    :returns: The output of the wavelet transform
    '''

    # Validate input path
    assert fp.endswith('.wav')

    # Load file
    segmented_data: List[List[int]] = []
    with open(fp, 'rb') as f:
        # Find data segment
        history: bytes = b''
        while f.peek() and history != b'data':
            history += f.read(1)
            history = history[-4:]

        # Read raw bytes until done
        chunk: bytes = f.read(SEGMENT_LENGTH * SKIP)
        while len(chunk) == SKIP:
            avgs: List[float] = []
            for i in range(0, SEGMENT_LENGTH * SKIP - SKIP, SKIP):
                avgs.append(np.mean([b for b in chunk[i:i+SKIP]]))

            segmented_data.append(avgs)
            chunk = f.read(SEGMENT_LENGTH * SKIP)

    # Perform transform
    tf_data: List[List[float]] = []
    for seg in segmented_data:
        tf_seg: List[List[float]] = dwt(seg, Wavelet('haar'))

        # Flatten
        l: List[float] = []
        for item in tf_seg:
            l += list(item)

        # Normalize
        m: float = np.mean(l)
        s: float = np.std(l)
        for i, item in enumerate(l):
            l[i] = (item - m) / s

        tf_data.append(l)

    return tf_data


if __name__ == '__main__':

    assert len(sys.argv) >= 2, 'Please provide a .wav file.'
    name: str = sys.argv[1]

    print(f'Loading file {name}...')

    data: List[List[float]] = load_file(name)
    n: int = len(data)
    n_bars: int = len(data[0])

    print('Graphing...')
    print(f'n {n} n_bars {n_bars}')

    min_y: float = 999999.0
    max_y: float = -min_y

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

        return data[i]

    def progress_update(cur: int, tot: int) -> None:
        '''
        Callback function for animation via FFMpeg
        '''

        p: float = round(100.0 * cur / tot, 2)
        print(f'{p}% done...')

    length: int = 60
    if len(sys.argv) == 3:
        length = int(sys.argv[2])

    fps: int = n // length
    x: Iterable = range(n_bars)
    fig = plt.figure()
    axes = fig.add_subplot(1, 1, 1)
    axes.set_ylim(min_y, max_y)
    bars = plt.bar(x, fn(0))
    peak_line = plt.axhline(y=0.0)
    trough_line = plt.axhline(y=0.0)

    def animate(i: int) -> None:
        '''
        Animation function, for the frame i.
        '''

        y = fn(i)
        peak: float = max(y)
        trough: float = min(y)
        if peak > 2.0:
            peak_line.set_ydata([peak])
        if trough < -2.0:
            trough_line.set_ydata([trough])

        for ind, b in enumerate(bars):
            b.set_height(y[ind])

    print(f'This video will be {n / fps} seconds long')

    print('Animating...')
    anim = animation.FuncAnimation(fig, animate, repeat=False,
                                   blit=False, frames=n)

    print('Saving...')
    anim.save(f'{name}.mp4',
              writer=animation.FFMpegWriter(fps=fps),
              progress_callback=progress_update)

    print('Done! Adding audio...')
    subprocess.run(['ffmpeg', '-i', f'{name}.mp4', '-i', name,
                    '-c', 'copy', '-map', '0:v:0', '-map',
                    '1:a:0', f'{name}-sound.mp4'],
                   check=True)
