# src/services/database_service.py
# ⚠️ OWNER: Dev 1 - All database operations go through this ⚠️

import hashlib
from datetime import datetime, timedelta, timezone
from typing import Any

from sqlalchemy import and_, desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.database import (
    BlacklistRecord,
    DocumentTypeEnum,
    HeatmapData,
    KYCRecord,
    ReportRecord,
    ReportStatusEnum,
    User,
    VerificationRecord,
    VerificationStatusEnum,
)


class DatabaseService:
    """Centralized database operations - ONLY DEV 1 MODIFIES THIS"""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    # ---------- USER OPERATIONS ----------
    async def create_user(self, **kwargs) -> User:
        user = User(**kwargs)
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user
    
    async def get_user(self, user_id: int) -> User | None:
        result = await self.session.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()
    
    async def get_user_by_email(self, email: str) -> User | None:
        result = await self.session.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def update_user(self, user_id: int, **kwargs) -> User | None:
        user = await self.get_user(user_id)
        if user:
            for key, value in kwargs.items():
                setattr(user, key, value)
            await self.session.commit()
            await self.session.refresh(user)
        return user
    
    # ---------- VERIFICATION OPERATIONS ----------
    async def create_verification(self, **kwargs) -> VerificationRecord:
        # Generate document hash for deduplication
        if 'document_number' in kwargs and 'document_type' in kwargs:
            doc_hash = hashlib.sha256(
                f"{kwargs['document_type']}:{kwargs['document_number']}".encode()
            ).hexdigest()
            kwargs['document_hash'] = doc_hash
        
        verification = VerificationRecord(**kwargs)
        self.session.add(verification)
        await self.session.commit()
        await self.session.refresh(verification)
        return verification
    
    async def get_verification(self, verification_id: int) -> VerificationRecord | None:
        result = await self.session.execute(
            select(VerificationRecord).where(VerificationRecord.id == verification_id)
        )
        return result.scalar_one_or_none()
    
    async def get_verifications_by_user(self, user_id: int, limit: int = 50) -> list[VerificationRecord]:
        result = await self.session.execute(
            select(VerificationRecord)
            .where(VerificationRecord.user_id == user_id)
            .order_by(desc(VerificationRecord.created_at))
            .limit(limit)
        )
        return result.scalars().all()
    
    async def update_verification_status(self, verification_id: int, status: VerificationStatusEnum) -> VerificationRecord | None:
        verification = await self.get_verification(verification_id)
        if verification:
            verification.status = status
            if status in [VerificationStatusEnum.VERIFIED, VerificationStatusEnum.FAKE]:
                verification.completed_at = datetime.now(timezone.utc)
            await self.session.commit()
            await self.session.refresh(verification)
        return verification
    
    async def get_high_risk_verifications(self, threshold: float = 70.0, limit: int = 100) -> list[VerificationRecord]:
        result = await self.session.execute(
            select(VerificationRecord)
            .where(VerificationRecord.risk_score >= threshold)
            .order_by(desc(VerificationRecord.risk_score))
            .limit(limit)
        )
        return result.scalars().all()
    
    # ---------- REPORT OPERATIONS ----------
    async def create_report(self, **kwargs) -> ReportRecord:
        # Generate FIR number
        import uuid
        kwargs['fir_number'] = f"FIR-{datetime.now(timezone.utc).year}-{uuid.uuid4().hex[:8].upper()}"
        
        report = ReportRecord(**kwargs)
        self.session.add(report)
        await self.session.commit()
        await self.session.refresh(report)
        return report
    
    async def get_report(self, report_id: int) -> ReportRecord | None:
        result = await self.session.execute(
            select(ReportRecord).where(ReportRecord.id == report_id)
        )
        return result.scalar_one_or_none()
    
    async def get_report_by_fir(self, fir_number: str) -> ReportRecord | None:
        result = await self.session.execute(
            select(ReportRecord).where(ReportRecord.fir_number == fir_number)
        )
        return result.scalar_one_or_none()
    
    async def get_reports_by_location(self, lat: float, lng: float, radius_km: float = 5.0) -> list[ReportRecord]:
        # Simple bounding box for now (you can add PostGIS later)
        delta = radius_km / 111.0  # Approximate degrees
        result = await self.session.execute(
            select(ReportRecord)
            .where(
                and_(
                    ReportRecord.location_lat.between(lat - delta, lat + delta),
                    ReportRecord.location_lng.between(lng - delta, lng + delta)
                )
            )
            .order_by(desc(ReportRecord.created_at))
        )
        return result.scalars().all()
    
    async def update_report_status(self, report_id: int, status: ReportStatusEnum) -> ReportRecord | None:
        report = await self.get_report(report_id)
        if report:
            report.status = status
            if status == ReportStatusEnum.RESOLVED:
                report.resolved_at = datetime.now(timezone.utc)
            await self.session.commit()
            await self.session.refresh(report)
        return report
    
    # ---------- KYC OPERATIONS ----------
    async def create_kyc_record(self, **kwargs) -> KYCRecord:
        import uuid
        kwargs['kyc_token'] = f"KYC-{uuid.uuid4().hex[:12].upper()}"
        kyc = KYCRecord(**kwargs)
        self.session.add(kyc)
        await self.session.commit()
        await self.session.refresh(kyc)
        return kyc
    
    async def get_kyc_by_token(self, token: str) -> KYCRecord | None:
        result = await self.session.execute(
            select(KYCRecord).where(KYCRecord.kyc_token == token)
        )
        return result.scalar_one_or_none()
    
    async def complete_kyc(self, token: str, shared_data: dict) -> KYCRecord | None:
        kyc = await self.get_kyc_by_token(token)
        if kyc:
            kyc.is_completed = True
            kyc.shared_data = shared_data
            kyc.completed_at = datetime.now(timezone.utc)
            await self.session.commit()
            await self.session.refresh(kyc)
        return kyc
    
    # ---------- HEATMAP OPERATIONS ----------
    async def add_heatmap_point(self, lat: float, lng: float, risk_score: float, fraud_category: str):
        heatmap = HeatmapData(
            location_lat=lat,
            location_lng=lng,
            risk_score=risk_score,
            fraud_category=fraud_category
        )
        self.session.add(heatmap)
        await self.session.commit()
        return heatmap
    
    async def get_heatmap_data(self, hours: int = 24) -> list[HeatmapData]:
        cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)
        result = await self.session.execute(
            select(HeatmapData)
            .where(HeatmapData.timestamp >= cutoff)
            .order_by(desc(HeatmapData.risk_score))
        )
        return result.scalars().all()
    
    async def get_heatmap_clusters(self, hours: int = 24) -> list[dict[str, Any]]:
        """Get aggregated heatmap data for clustering"""
        cutoff = datetime.now(timezone.utc) - timedelta(hours=hours)
        result = await self.session.execute(
            select(
                HeatmapData.location_lat,
                HeatmapData.location_lng,
                func.avg(HeatmapData.risk_score).label('avg_risk'),
                func.count(HeatmapData.id).label('count')
            )
            .where(HeatmapData.timestamp >= cutoff)
            .group_by(HeatmapData.location_lat, HeatmapData.location_lng)
            .having(func.count(HeatmapData.id) >= 3)
            .order_by(desc('avg_risk'))
        )
        return [row._asdict() for row in result.all()]
    
    # ---------- BLACKLIST OPERATIONS ----------
    async def add_to_blacklist(self, document_number: str, document_type: DocumentTypeEnum, reason: str, source: str) -> BlacklistRecord:
        blacklist = BlacklistRecord(
            document_number=document_number,
            document_type=document_type,
            reason=reason,
            source=source
        )
        self.session.add(blacklist)
        await self.session.commit()
        await self.session.refresh(blacklist)
        return blacklist
    
    async def check_blacklist(self, document_number: str) -> BlacklistRecord | None:
        result = await self.session.execute(
            select(BlacklistRecord)
            .where(
                and_(
                    BlacklistRecord.document_number == document_number,
                    BlacklistRecord.is_active == True
                )
            )
        )
        return result.scalar_one_or_none()
    
    # ---------- STATISTICS (For Dashboard) ----------
    async def get_dashboard_stats(self) -> dict[str, Any]:
        # Total verifications today
        today = datetime.now(timezone.utc).date()
        total_verifications = await self.session.execute(
            select(func.count(VerificationRecord.id))
            .where(func.date(VerificationRecord.created_at) == today)
        )
        
        # Fake documents today
        fake_documents = await self.session.execute(
            select(func.count(VerificationRecord.id))
            .where(
                and_(
                    func.date(VerificationRecord.created_at) == today,
                    VerificationRecord.status == VerificationStatusEnum.FAKE
                )
            )
        )
        
        # Active reports
        active_reports = await self.session.execute(
            select(func.count(ReportRecord.id))
            .where(ReportRecord.status != ReportStatusEnum.CLOSED)
        )
        
        # Average risk score
        avg_risk = await self.session.execute(
            select(func.avg(VerificationRecord.risk_score))
            .where(func.date(VerificationRecord.created_at) == today)
        )
        
        return {
            "total_verifications": total_verifications.scalar() or 0,
            "fake_documents": fake_documents.scalar() or 0,
            "active_reports": active_reports.scalar() or 0,
            "average_risk_score": float(avg_risk.scalar() or 0),
            "timestamp": datetime.now(timezone.utc).isoformat()
        }