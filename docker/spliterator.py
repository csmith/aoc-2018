import json

with open('2018.ipynb', 'r') as f:
    notebook = json.load(f)
    common = ''
    days = {}

    for cell in notebook['cells']:
        if cell['cell_type'] == 'code':
            day = cell['metadata']['day']
            if day == 0:
                common += ''.join(cell['source']) + '\n'
            else:
                if day not in days:
                    days[day] = common
                days[day] += ''.join(cell['source'][:-1])
                days[day] += f"print({cell['source'][-1]})\n\n"

    for day, code in days.items():
        with open(f"{day:02}.py", "w") as py:
            print(f'Writing day {day}...')
            py.write(code)
