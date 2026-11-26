#include <QuartzCore/CATransform3D.h>

#include <math.h>
#include <stdint.h>
#include <string.h>

/* Render-server debug controls have no window-server backend in Darling. */
void CARenderServerClearDebugOptions(int port)
{
	(void) port;
}

int CARenderServerGetDebugOption(int port, int option)
{
	(void) port;
	(void) option;
	return 0;
}

uint64_t CARenderServerGetFrameCounter(int port)
{
	(void) port;
	return 0;
}

void CARenderServerSetDebugOption(int port, int option, int value)
{
	(void) port;
	(void) option;
	(void) value;
}

static void transformToArray(CATransform3D transform, CGFloat values[16])
{
	const CGFloat result[16] = {
		transform.m11, transform.m12, transform.m13, transform.m14,
		transform.m21, transform.m22, transform.m23, transform.m24,
		transform.m31, transform.m32, transform.m33, transform.m34,
		transform.m41, transform.m42, transform.m43, transform.m44
	};
	memcpy(values, result, sizeof(result));
}

static CATransform3D arrayToTransform(const CGFloat values[16])
{
	CATransform3D result = {
		values[0], values[1], values[2], values[3],
		values[4], values[5], values[6], values[7],
		values[8], values[9], values[10], values[11],
		values[12], values[13], values[14], values[15]
	};
	return result;
}

CATransform3D CATransform3DConcat(CATransform3D a, CATransform3D b)
{
	CGFloat left[16], right[16], result[16];
	transformToArray(a, left);
	transformToArray(b, right);
	for (int row = 0; row < 4; ++row) {
		for (int column = 0; column < 4; ++column) {
			CGFloat value = 0;
			for (int index = 0; index < 4; ++index)
				value += left[row * 4 + index] * right[index * 4 + column];
			result[row * 4 + column] = value;
		}
	}
	return arrayToTransform(result);
}

bool CATransform3DEqualToTransform(CATransform3D a, CATransform3D b)
{
	CGFloat left[16], right[16];
	transformToArray(a, left);
	transformToArray(b, right);
	for (int index = 0; index < 16; ++index) {
		if (left[index] != right[index])
			return false;
	}
	return true;
}

CATransform3D CATransform3DInvert(CATransform3D transform)
{
	CGFloat source[16];
	double matrix[4][8];
	transformToArray(transform, source);
	for (int row = 0; row < 4; ++row) {
		for (int column = 0; column < 4; ++column)
			matrix[row][column] = source[row * 4 + column];
		for (int column = 0; column < 4; ++column)
			matrix[row][column + 4] = row == column ? 1.0 : 0.0;
	}

	for (int column = 0; column < 4; ++column) {
		int pivot = column;
		for (int row = column + 1; row < 4; ++row) {
			if (fabs(matrix[row][column]) > fabs(matrix[pivot][column]))
				pivot = row;
		}
		if (matrix[pivot][column] == 0.0)
			return transform;
		if (pivot != column) {
			for (int index = 0; index < 8; ++index) {
				double swap = matrix[pivot][index];
				matrix[pivot][index] = matrix[column][index];
				matrix[column][index] = swap;
			}
		}

		double divisor = matrix[column][column];
		for (int index = 0; index < 8; ++index)
			matrix[column][index] /= divisor;
		for (int row = 0; row < 4; ++row) {
			if (row == column)
				continue;
			double factor = matrix[row][column];
			for (int index = 0; index < 8; ++index)
				matrix[row][index] -= factor * matrix[column][index];
		}
	}

	CGFloat inverse[16];
	for (int row = 0; row < 4; ++row)
		for (int column = 0; column < 4; ++column)
			inverse[row * 4 + column] = (CGFloat) matrix[row][column + 4];
	return arrayToTransform(inverse);
}

bool CATransform3DIsIdentity(CATransform3D transform)
{
	return CATransform3DEqualToTransform(transform, CATransform3DIdentity);
}

bool CATransform3DIsAffine(CATransform3D t)
{
	return t.m13 == 0 && t.m14 == 0 && t.m23 == 0 && t.m24 == 0 &&
	       t.m31 == 0 && t.m32 == 0 && t.m33 == 1 && t.m34 == 0 &&
	       t.m43 == 0 && t.m44 == 1;
}

CATransform3D CATransform3DMakeAffineTransform(CGAffineTransform m)
{
	CATransform3D result = CATransform3DIdentity;
	result.m11 = m.a;
	result.m12 = m.b;
	result.m21 = m.c;
	result.m22 = m.d;
	result.m41 = m.tx;
	result.m42 = m.ty;
	return result;
}

CGAffineTransform CATransform3DGetAffineTransform(CATransform3D t)
{
	return CGAffineTransformMake(t.m11, t.m12, t.m21, t.m22, t.m41, t.m42);
}

CATransform3D CATransform3DMakeRotation(CGFloat angle, CGFloat x, CGFloat y, CGFloat z)
{
	double length = sqrt((double) x * x + (double) y * y + (double) z * z);
	if (length == 0.0)
		return CATransform3DIdentity;

	double nx = x / length;
	double ny = y / length;
	double nz = z / length;
	double cosine = cos(angle);
	double sine = sin(angle);
	double complement = 1.0 - cosine;
	CATransform3D result = CATransform3DIdentity;
	result.m11 = (CGFloat) (cosine + nx * nx * complement);
	result.m12 = (CGFloat) (nx * ny * complement + nz * sine);
	result.m13 = (CGFloat) (nx * nz * complement - ny * sine);
	result.m21 = (CGFloat) (ny * nx * complement - nz * sine);
	result.m22 = (CGFloat) (cosine + ny * ny * complement);
	result.m23 = (CGFloat) (ny * nz * complement + nx * sine);
	result.m31 = (CGFloat) (nz * nx * complement + ny * sine);
	result.m32 = (CGFloat) (nz * ny * complement - nx * sine);
	result.m33 = (CGFloat) (cosine + nz * nz * complement);
	return result;
}

CATransform3D CATransform3DMakeScale(CGFloat sx, CGFloat sy, CGFloat sz)
{
	CATransform3D result = CATransform3DIdentity;
	result.m11 = sx;
	result.m22 = sy;
	result.m33 = sz;
	return result;
}

CATransform3D CATransform3DMakeTranslation(CGFloat tx, CGFloat ty, CGFloat tz)
{
	CATransform3D result = CATransform3DIdentity;
	result.m41 = tx;
	result.m42 = ty;
	result.m43 = tz;
	return result;
}

CATransform3D CATransform3DRotate(CATransform3D transform, CGFloat angle,
									 CGFloat x, CGFloat y, CGFloat z)
{
	return CATransform3DConcat(CATransform3DMakeRotation(angle, x, y, z), transform);
}

CATransform3D CATransform3DScale(CATransform3D transform, CGFloat sx, CGFloat sy, CGFloat sz)
{
	return CATransform3DConcat(CATransform3DMakeScale(sx, sy, sz), transform);
}

CATransform3D CATransform3DTranslate(CATransform3D transform, CGFloat tx, CGFloat ty, CGFloat tz)
{
	return CATransform3DConcat(CATransform3DMakeTranslation(tx, ty, tz), transform);
}
