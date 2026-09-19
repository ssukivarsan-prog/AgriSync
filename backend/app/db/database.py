import os
import datetime
from pathlib import Path
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from backend.app.core.config import settings
from backend.app.db.models import Base, Farm, Field, SensorReading, Alert
import backend.app.db.admin_models # Register admin models on Base.metadata

# Create async engine for SQLite
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=False,
    future=True
)

async_session_maker = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def get_db():
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

async def init_db():
    # Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Seed initial demo farm and fields if empty
    async with async_session_maker() as session:
        from sqlalchemy import select
        res = await session.execute(select(Farm))
        existing_farm = res.scalars().first()
        
        if not existing_farm:
            demo_farm = Farm(
                name="AgriSync Green Valley Demo Farm",
                location="Pune District, Maharashtra, India",
                total_area_acres=15.0
            )
            session.add(demo_farm)
            await session.flush()

            fields = [
                Field(farm_id=demo_farm.id, name="North Field A", crop="Tomato", variety="Arka Rakshak", growth_stage="Flowering", soil_type="Loamy", area_acres=4.0),
                Field(farm_id=demo_farm.id, name="South Field B", crop="Potato", variety="Kufri Jyoti", growth_stage="Tuber Formation", soil_type="Sandy Loam", area_acres=3.5),
                Field(farm_id=demo_farm.id, name="East Field C", crop="Corn (Maize)", variety="Ganga-11", growth_stage="Vegetative", soil_type="Clay Loam", area_acres=5.0),
                Field(farm_id=demo_farm.id, name="Greenhouse Zone 1", crop="Bell Pepper", variety="Indra", growth_stage="Fruiting", soil_type="Loamy", area_acres=2.5),
            ]
            session.add_all(fields)
            await session.flush()

            # Seed demo sensor readings
            now = datetime.datetime.utcnow()
            for f in fields:
                reading = SensorReading(
                    field_id=f.id,
                    device_id=f"IOT-AGRI-00{f.id}",
                    soil_moisture=26.5 if f.name == "North Field A" else 38.0,
                    temperature=31.8,
                    humidity=58.0,
                    rainfall=0.0,
                    is_demo=True,
                    timestamp=now
                )
                session.add(reading)

            # Seed sample alerts
            alert1 = Alert(
                field_id=fields[0].id,
                severity="HIGH",
                title="Low Soil Moisture Detected",
                message="Soil moisture in North Field A dropped to 26.5%, approaching the critical threshold for flowering Tomato.",
                action_needed="Schedule a 45-minute drip irrigation cycle before 10:00 AM.",
                is_resolved=False,
                timestamp=now - datetime.timedelta(hours=2)
            )
            alert2 = Alert(
                field_id=fields[0].id,
                severity="MODERATE",
                title="Disease-Favorable Humidity Alert",
                message="Relative humidity expected to exceed 75% tonight with temperatures around 23°C, favoring Early Blight incubation.",
                action_needed="Inspect lower canopy leaves tomorrow morning; avoid overhead sprinkler wetting.",
                is_resolved=False,
                timestamp=now - datetime.timedelta(hours=5)
            )
            session.add_all([alert1, alert2])

            await session.commit()
            print("Initialized AgriSync database and seeded baseline demo data successfully.")

        # Seed admin village and farmers cohort if needed
        from backend.app.db.seed_admin import seed_admin_village_data
        await seed_admin_village_data(session)
