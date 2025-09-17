import streamlit as st
import pandas as pd
import time
from datetime import datetime

CSV_PATH = "morning_log.csv"

# --- Configuración de página ---
st.set_page_config(page_title="🌸 Morning Tracker", page_icon="✨", layout="centered")
st.title("🌸 Morning Tracker")
st.caption("Mide y guarda cuánto duran tus rutinas de la mañana")

# --- Actividades fijas ---
activities = [
    "⏰ Levantarme",
    "🌬 Respiración 4-4-8",
    "📓 Journal",
    "🛏 Tender cama",
    "🚿 Baño & Arreglo",
    "🍳 Desayuno",
    "🐶 Sacar a Alana",
    "💻 Empezar a trabajar"
]

# --- Cargar CSV ---
def load_csv():
    try:
        return pd.read_csv(CSV_PATH)
    except:
        return pd.DataFrame(columns=["Actividad", "Inicio", "Fin", "Duración_min"])

def save_csv(df):
    df.to_csv(CSV_PATH, index=False)

# --- Estado de sesión para el cronómetro ---
if "running" not in st.session_state:
    st.session_state.running = False
if "start_time" not in st.session_state:
    st.session_state.start_time = None
if "activity" not in st.session_state:
    st.session_state.activity = None

# --- Grid de botones (2 columnas girly) ---
cols = st.columns(2)
for i, act in enumerate(activities):
    if cols[i % 2].button(act, use_container_width=True):
        if not st.session_state.running:  # empezar cronómetro
            st.session_state.running = True
            st.session_state.start_time = time.time()
            st.session_state.activity = act
            st.success(f"⏱ Empezaste: {act}")

# --- Mostrar cronómetro activo ---
if st.session_state.running:
    elapsed = int(time.time() - st.session_state.start_time)
    mins, secs = divmod(elapsed, 60)
    st.markdown(f"### ⏱ {st.session_state.activity}: {mins:02d}:{secs:02d}")
    if st.button("🛑 Stop", use_container_width=True):
        st.session_state.running = False
        end_time = time.time()
        dur_min = round((end_time - st.session_state.start_time) / 60, 1)

        df = load_csv()
        new_row = {
            "Actividad": st.session_state.activity,
            "Inicio": datetime.fromtimestamp(st.session_state.start_time).strftime("%H:%M:%S"),
            "Fin": datetime.fromtimestamp(end_time).strftime("%H:%M:%S"),
            "Duración_min": dur_min
        }
        df = pd.concat([df, pd.DataFrame([new_row])], ignore_index=True)
        save_csv(df)

        st.success(f"✅ Guardado: {st.session_state.activity} — {dur_min} min")

# --- Tabla de registros ---
st.markdown("## 📋 Registros de hoy")
df = load_csv()
if not df.empty:
    st.dataframe(df, use_container_width=True)
else:
    st.info("Aún no hay actividades registradas.")
