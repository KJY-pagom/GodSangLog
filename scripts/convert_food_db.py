"""
엑셀 식품 영양 DB → SQLite 변환 스크립트
출력: assets/food_db.sqlite

사용법: python scripts/convert_food_db.py
"""

import sqlite3
import os
import pandas as pd

FOOD_DB_XLSX = "C:/Users/YI-L080/Downloads/20250408_음식DB.xlsx"
PROCESSED_XLSX = "C:/Users/YI-L080/Downloads/20260309_가공식품_256741건.xlsx"
OUTPUT_DB = os.path.join(os.path.dirname(__file__), "..", "assets", "food_db.sqlite")

COLS = {
    "식품명": "name",
    "에너지(kcal)": "calories",
    "단백질(g)": "protein",
    "지방(g)": "fat",
    "탄수화물(g)": "carbs",
    "영양성분함량기준량": "serving_raw",
}


def parse_serving(val) -> float:
    """'100g', '200g' 등 문자열에서 숫자 추출. 숫자면 그대로 반환."""
    if val is None or (isinstance(val, float) and pd.isna(val)):
        return 100.0
    s = str(val).strip().replace("g", "").replace("G", "")
    try:
        return float(s)
    except ValueError:
        return 100.0


def load_excel(path: str, source: str) -> pd.DataFrame:
    print(f"  로딩 중: {os.path.basename(path)}")
    usecols = list(COLS.keys())
    df = pd.read_excel(path, usecols=usecols, dtype=str)
    df = df.rename(columns=COLS)
    df["serving_size"] = df["serving_raw"].apply(parse_serving)
    df["source"] = source

    for col in ("calories", "protein", "fat", "carbs"):
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0.0)

    df = df[["name", "calories", "protein", "fat", "carbs", "serving_size", "source"]]
    df = df[df["name"].notna() & (df["name"].str.strip() != "")]
    df["name"] = df["name"].str.strip().str.lstrip("\ufeff")
    return df


def main():
    os.makedirs(os.path.dirname(OUTPUT_DB), exist_ok=True)

    print("=== 식품 DB 변환 시작 ===")

    print("[1/2] 음식DB 로딩...")
    df1 = load_excel(FOOD_DB_XLSX, "food")
    print(f"  → {len(df1):,}건")

    print("[2/2] 가공식품DB 로딩...")
    df2 = load_excel(PROCESSED_XLSX, "processed")
    print(f"  → {len(df2):,}건")

    combined = pd.concat([df1, df2], ignore_index=True)
    combined = combined.drop_duplicates(subset=["name", "calories"], keep="first")
    print(f"\n총 {len(combined):,}건 (중복 제거 후)")

    if os.path.exists(OUTPUT_DB):
        os.remove(OUTPUT_DB)

    print(f"\nSQLite 생성 중: {OUTPUT_DB}")
    conn = sqlite3.connect(OUTPUT_DB)
    cur = conn.cursor()

    cur.execute("""
        CREATE TABLE foods (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT NOT NULL,
            calories    REAL NOT NULL DEFAULT 0,
            protein     REAL NOT NULL DEFAULT 0,
            fat         REAL NOT NULL DEFAULT 0,
            carbs       REAL NOT NULL DEFAULT 0,
            serving_size REAL NOT NULL DEFAULT 100,
            source      TEXT
        )
    """)

    # 이름으로 빠른 LIKE 검색을 위한 인덱스
    cur.execute("CREATE INDEX idx_foods_name ON foods(name COLLATE NOCASE)")

    rows = [
        (
            row.name,
            round(row.calories, 2),
            round(row.protein, 2),
            round(row.fat, 2),
            round(row.carbs, 2),
            round(row.serving_size, 1),
            row.source,
        )
        for row in combined.itertuples(index=False)
    ]

    cur.executemany(
        "INSERT INTO foods(name, calories, protein, fat, carbs, serving_size, source) VALUES(?,?,?,?,?,?,?)",
        rows,
    )

    conn.commit()

    row_count = cur.execute("SELECT COUNT(*) FROM foods").fetchone()[0]
    db_size_mb = os.path.getsize(OUTPUT_DB) / (1024 * 1024)
    conn.close()

    print(f"완료! 저장 건수: {row_count:,}건, 파일 크기: {db_size_mb:.1f}MB")
    print(f"출력 파일: {OUTPUT_DB}")


if __name__ == "__main__":
    main()
