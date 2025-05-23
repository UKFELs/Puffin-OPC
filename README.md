# 💫 Puffin–OPC Field Conversion Toolkit

This repository contains Python scripts for converting electromagnetic field data between **Puffin** and **OPC (Optical Propagation Code)** formats. This allows for seamless integration of unaveraged, cavity-based FEL simulations with optical beamline propagation studies.

- 🔗 [Puffin repository](https://github.com/UKFELs/Puffin)
- 🔗 [OPC repository](https://gitlab.utwente.nl/tnw/ap/lpno/public-projects/Physics-OPC)

---

## 🔄 Conversion: Puffin → OPC

To propagate radiation fields generated by Puffin through optical components using OPC:

### 🧪 Example

If your Puffin simulation was configured for `40` undulator periods and used `test.in`, and the field was dumped every period, the file:
```
test_aperp_41
```
will contain the final output field at the undulator exit.

Run the following command:
```bash
python /path/to/python-scripts/Puffin-to-OPC_xy.py test_aperp_41
```

This will generate:
- `test_aperp_41_x.dfl` & `test_aperp_41_x.param`
- `test_aperp_41_y.dfl` & `test_aperp_41_y.param`

These represent orthogonal polarization components and are directly usable as OPC input fields. See the `./example` directory for sample usage, including how to run propagation using OPC scripts (e.g., `bash`, `perl`).

> 🛠 Need to build OPC on HPC like LANTA? Check out the companion guide:  
> [BUILD_OPC_LANTA.md](./BUILD_OPC_LANTA.md)
> [BUILD_PUFFIN_LANTA.md](./BUILD_PUFFIN_LANTA.md)

---

## 🔄 Conversion: OPC → Puffin

To seed a Puffin simulation using field output from OPC:

Ensure you have the following OPC output files:
- `entrance_x.dfl` & `entrance_x.param`
- `entrance_y.dfl` & `entrance_y.param`

Then run:
```bash
python /path/to/python-scripts/OPC-to-Puffin_xy.py entrance
```

This creates:
```
entrance.h5
```

This file is compatible as a restart or seed field in Puffin.

---

## 📁 Folder Structure

```
python-scripts/
├── Puffin-to-OPC_xy.py
├── OPC-to-Puffin_xy.py
examples/
└── test_aperp_41 (sample field)
```

---

## 🧠 Notes

- Polarization components `x` and `y` are extracted and propagated independently when converting between formats, ensuring compatibility and accuracy in simulation chains.

---

## 👤 Author

Racha Pongchalee – [SLRI], formerly at [University of Strathclyde]

---

For more information on integrating FEL simulations with optical modeling workflows, feel free to reach out or contribute to this toolkit.
