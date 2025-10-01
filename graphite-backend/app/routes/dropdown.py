# ========================================
# File: app/routes/dropdown.py
# Simplified Dropdown Routes (Phase 4A Task 2)
# Changes:
# - Removed permission checks (all users can add to searchable fields)
# - Removed approval workflow
# - Simplified API responses
# ========================================

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, verify_jwt_in_request
from app import db
from app.models.user import User
from app.models.dropdown import DropdownOption, DropdownField
from app.models.system_log import SystemLog

dropdown_bp = Blueprint('dropdown', __name__)

# ==========================================
# Main Dropdown APIs
# ==========================================

@dropdown_bp.route('/options/<string:field_name>', methods=['GET', 'OPTIONS'])
def get_dropdown_options_by_path(field_name):
    """Get dropdown options by field name (supports CORS preflight)"""
    # Handle OPTIONS preflight request
    if request.method == 'OPTIONS':
        return '', 200
    
    try:
        search = request.args.get('search', '')
        
        # Build query
        query = DropdownOption.query.filter_by(
            field_name=field_name, 
            is_active=True
        )
        
        # Search functionality
        if search and len(search) >= 2:
            query = query.filter(
                db.or_(
                    DropdownOption.option_value.contains(search),
                    DropdownOption.option_label.contains(search)
                )
            )
        
        options = query.order_by(DropdownOption.sort_order).limit(20).all()
        
        result = [{
            'id': option.id,
            'value': option.option_value,
            'label': option.option_label,
            'sort_order': option.sort_order
        } for option in options]
        
        return jsonify(result), 200
        
    except Exception as e:
        print(f"Error getting options: {str(e)}")
        return jsonify({'error': 'Failed to get options', 'message': str(e)}), 500


@dropdown_bp.route('/options', methods=['GET'])
@jwt_required()
def get_dropdown_options():
    """Get dropdown options (query parameter version, kept for compatibility)"""
    try:
        field_name = request.args.get('field_name')
        search = request.args.get('search', '')
        
        if not field_name:
            return jsonify({'error': 'Field name is required'}), 400
        
        # Build query
        query = DropdownOption.query.filter_by(
            field_name=field_name, 
            is_active=True
        )
        
        # Search functionality
        if search and len(search) >= 2:
            query = query.filter(
                db.or_(
                    DropdownOption.option_value.contains(search),
                    DropdownOption.option_label.contains(search)
                )
            )
        
        options = query.order_by(DropdownOption.sort_order).limit(20).all()
        
        result = [{
            'value': option.option_value,
            'label': option.option_label,
            'sort_order': option.sort_order
        } for option in options]
        
        return jsonify({'options': result}), 200
        
    except Exception as e:
        return jsonify({'error': 'Failed to get options'}), 500


@dropdown_bp.route('/add', methods=['POST', 'OPTIONS'])
@jwt_required(optional=True)  # Make JWT optional to handle OPTIONS
def add_dropdown_option():
    """
    Add new dropdown option (SIMPLIFIED - Phase 4A Task 2)
    
    Changes:
    - Removed all permission checks
    - Removed approval workflow
    - All users can add to searchable fields
    - Only check: field must be 'searchable' type
    """
    # Handle OPTIONS preflight request
    if request.method == 'OPTIONS':
        return '', 200
        
    try:
        # Get current user from JWT
        current_user_id = get_jwt_identity()
        if not current_user_id:
            return jsonify({'error': 'Authentication required'}), 401
        
        user = User.query.get(current_user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        data = request.get_json()
        field_name = data.get('field_name')
        option_value = data.get('option_value')
        option_label = data.get('option_label')
        
        # Validate required fields
        if not all([field_name, option_value, option_label]):
            return jsonify({'error': 'Field name, option value and label are required'}), 400
        
        # Check field configuration
        field_config = DropdownField.query.filter_by(field_name=field_name).first()
        if not field_config:
            return jsonify({'error': 'Field does not exist'}), 400
        
        # NEW: Simplified check - only verify field type is searchable
        if field_config.field_type == 'fixed':
            return jsonify({'error': 'Cannot add options to fixed fields'}), 400
        
        # REMOVED: Permission checks (allow_user_add, allow_engineer_add, etc.)
        # REMOVED: Approval workflow (require_approval)
        
        # Check if option already exists
        existing = DropdownOption.query.filter_by(
            field_name=field_name,
            option_value=option_value
        ).first()
        
        if existing:
            return jsonify({'error': 'Option already exists'}), 400
        
        # REMOVED: Max options limit check (field_config.max_options)
        
        # Add option directly (no approval needed)
        # Get next sort order
        max_sort = db.session.query(db.func.max(DropdownOption.sort_order)).filter_by(
            field_name=field_name
        ).scalar() or 0
        
        option = DropdownOption(
            field_name=field_name,
            option_value=option_value,
            option_label=option_label,
            sort_order=max_sort + 1,
            created_by=current_user_id
        )
        db.session.add(option)
        db.session.commit()
        
        # Log action (optional, keep for audit trail)
        try:
            SystemLog.log_action(
                user_id=current_user_id,
                action='add_dropdown_option',
                description=f'Added option: {field_name} - {option_label}',
                ip_address=request.remote_addr
            )
        except:
            pass  # Don't fail if logging fails
        
        return jsonify({
            'success': True,
            'message': 'Option added successfully',
            'option': {
                'id': option.id,
                'value': option.option_value,
                'label': option.option_label
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"Error adding option: {str(e)}")
        return jsonify({'error': 'Failed to add option', 'message': str(e)}), 500


@dropdown_bp.route('/fields', methods=['GET'])
@jwt_required()
def get_dropdown_fields():
    """
    Get dropdown field configurations (SIMPLIFIED)
    
    Returns only essential field information:
    - field_name, field_label, field_type
    """
    try:
        fields = DropdownField.query.all()
        
        result = []
        for field in fields:
            field_data = {
                'field_name': field.field_name,
                'field_label': field.field_label,
                'field_type': field.field_type,
                # REMOVED: Permission fields (allow_user_add, require_approval, etc.)
            }
            result.append(field_data)
        
        return jsonify({'fields': result}), 200
        
    except Exception as e:
        return jsonify({'error': 'Failed to get field configurations'}), 500


# ==========================================
# DEPRECATED: Approval-related endpoints
# These are kept for backward compatibility but should not be used
# ==========================================

@dropdown_bp.route('/approvals', methods=['GET'])
@jwt_required()
def get_dropdown_approvals():
    """
    DEPRECATED: Get pending approvals
    Returns empty list as approval workflow is removed
    """
    return jsonify({'approvals': [], 'message': 'Approval workflow has been removed'}), 200


@dropdown_bp.route('/approve/<int:approval_id>', methods=['POST'])
@jwt_required()
def approve_dropdown_option(approval_id):
    """
    DEPRECATED: Approve dropdown option
    Returns error as approval workflow is removed
    """
    return jsonify({'error': 'Approval workflow has been removed'}), 400


@dropdown_bp.route('/reject/<int:approval_id>', methods=['POST'])
@jwt_required()
def reject_dropdown_option(approval_id):
    """
    DEPRECATED: Reject dropdown option
    Returns error as approval workflow is removed
    """
    return jsonify({'error': 'Approval workflow has been removed'}), 400


# ==========================================
# Health Check
# ==========================================

@dropdown_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'version': 'Phase 4A - Simplified',
        'features': {
            'approval_workflow': False,
            'permission_checks': False,
            'all_users_can_add_searchable': True
        }
    }), 200